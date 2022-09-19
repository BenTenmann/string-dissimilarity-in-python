import os
from itertools import combinations
from pathlib import Path

import numpy as np
import pandas as pd
from scipy.spatial.distance import squareform
from sklearn.manifold import MDS

DATA_DIR = os.environ.get("DATA_DIR")
OUTPUT_DIR = os.environ.get("OUTPUT_DIR")


def get_metric_data_paths(data_dir: str):
    return Path(data_dir).glob("*.npy")


def matrix_norm(a: np.ndarray, b: np.ndarray) -> np.ndarray:
    return np.linalg.norm(a - b)


def compute_distance_matrix(data_dir: str) -> np.ndarray:
    return squareform(
        [
            matrix_norm(a, b)
            for a, b in combinations(
                map(np.load, map(str, get_metric_data_paths(data_dir))), r=2
            )
        ]
    )


def compute_embeddings(distance_matrix: np.ndarray) -> np.ndarray:
    return MDS(dissimilarity="precomputed").fit_transform(distance_matrix)


def main():
    pd.DataFrame(
        compute_embeddings(compute_distance_matrix(DATA_DIR)),
        columns=["mds_1", "mds_2"],
    ).assign(metric=[p.stem for p in get_metric_data_paths(DATA_DIR)]).to_csv(
        Path(OUTPUT_DIR) / "diff_metrics.csv"
    )


if __name__ == "__main__":
    main()
