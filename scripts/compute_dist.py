import os
from pathlib import Path

import numpy as np
import pandas as pd
import setriq
import srsly
from scipy.spatial.distance import squareform
from sklearn.manifold import MDS

PIPELINE_SPEC = os.environ.get("PIPELINE_SPEC")
DATA_PATH = os.environ.get("DATA_PATH")
OUTPUT_PATH = os.environ.get("OUTPUT_PATH", "dist.csv")


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

    metr_spec: dict = manifest["metric"]
    metric = getattr(setriq, metr_spec["name"])(**metr_spec.get("param", {}))

    df = get_data(
        DATA_PATH,
        max_samples=manifest["n_samples"],
        max_ann=manifest["n_ann"],
        ann=manifest["ann"],
        keep_ann=manifest.get("keep_ann"),
    )

    print(f"computing {manifest['n_samples']} distances")
    distances = squareform(metric(df["cdr3"]))
    np.save(str(Path(OUTPUT_PATH).parent / f"{metr_spec['name'].lower()}"), distances)

    print("computing the MDS")
    embedding = MDS(dissimilarity="precomputed").fit_transform(distances)

    pd.DataFrame(embedding, columns=["mds_1", "mds_2"]).assign(
        epitope=df["epitope"], gene=df["gene"], species=df["species"]
    ).to_csv(OUTPUT_PATH)


if __name__ == "__main__":
    main()
