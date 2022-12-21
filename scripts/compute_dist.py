import os
from pathlib import Path
from typing import Dict, Type, TypeVar

import numpy as np
import pandas as pd
import setriq
import srsly
from sklearn import (
    manifold,
    metrics,
)

PIPELINE_SPEC = os.environ.get("PIPELINE_SPEC")
DATA_PATH = os.environ.get("DATA_PATH")
OUTPUT_PATH = os.environ.get("OUTPUT_PATH", "dist.csv")

Metric = TypeVar("Metric", bound=Type[setriq.modules.distances.Metric])


def get_data(
    path: str,
    max_samples: int,
    max_ann: int = 10,
    ann: str = "epitope",
    keep_ann: list = None,
) -> pd.DataFrame:
    keep_ann = keep_ann or []
    df = pd.read_csv(path, header=None, names=["cdr3", "epitope", "gene", "species"])

    return (
        df.loc[
            df[ann].isin(
                keep_ann
                if bool(keep_ann)
                else df.groupby(ann).size().sort_values(ascending=False).index[:max_ann]
            )
        ]
        .groupby(ann)
        .apply(lambda e: e.iloc[: max_samples // (len(keep_ann) or max_ann)])
        .reset_index(drop=True)
    )


def main():
    manifest = srsly.read_yaml(PIPELINE_SPEC)

    metr_spec: Dict[str, str] = manifest["metric"]
    metric_type: Metric = getattr(setriq, metr_spec["name"])
    metric = metric_type(**metr_spec.get("param", {}), return_squareform=True)

    df = get_data(
        DATA_PATH,
        max_samples=manifest["n_samples"],
        max_ann=manifest["n_ann"],
        ann=manifest["ann"],
        keep_ann=manifest.get("keep_ann"),
    )

    print(f"computing {manifest['n_samples']} distances")
    distances = metric(df["cdr3"])
    np.save(str(Path(OUTPUT_PATH).parent / f"{metr_spec['name'].lower()}"), distances)

    print("computing the MDS")
    embedding = manifold.TSNE(metric="precomputed", random_state=42).fit_transform(distances)

    pd.DataFrame(embedding, columns=["t0", "t1"]).assign(
        epitope=df["epitope"], gene=df["gene"], species=df["species"]
    ).to_csv(OUTPUT_PATH)

    print("Computing silhouette score")
    pd.DataFrame(
        [(metr_spec["name"], metrics.silhouette_score(distances, df["gene"], metric="precomputed"))],
        columns=["metric", "silhouette_score"]
    ).to_csv(Path(OUTPUT_PATH).parent / "silhouette_score.csv", mode="a", index=False, header=False)


if __name__ == "__main__":
    main()
