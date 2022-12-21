import os
from pathlib import Path

import numpy as np
import pandas as pd

DATA_DIR = os.environ.get("DATA_DIR")
OUTPUT_DIR = os.environ.get("OUTPUT_DIR")


def load_condensed_distance_matrix(file: Path) -> np.ndarray:
    D = np.load(file.as_posix())
    return D[np.tril_indices_from(D, k=-1)]


def main():
    pd.concat([
        pd.Series(load_condensed_distance_matrix(file)).rename(file.stem)
        for file in Path(DATA_DIR).glob("*.npy")
    ], axis=1).corr(method="spearman")\
        .melt(var_name="to", value_name="spearman_r", ignore_index=False)\
        .reset_index()\
        .rename(columns={"index": "from"}) \
        .to_csv(Path(OUTPUT_DIR) / "corr_metrics.csv", index=False)


if __name__ == "__main__":
    main()
