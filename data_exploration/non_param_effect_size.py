import numpy as np
from scipy import stats


# ---------------------------
# Independent samples -------
# ---------------------------
def cles_ind(x1, x2):
    """Calc common language effect size

    Interpret as the probability that a score sampled
    at random from one distribution will be greater than
    a score sampled from some other distribution.

    Based on: http://psycnet.apa.org/doi/10.1037/0033-2909.111.2.361

    :param x1: sample 1
    :param x2: sample 2
    :return: (float) common language effect size
    """
    x1 = np.array(x1)
    x2 = np.array(x2)

    diff = x1[:, None] - x2
    cles = max((diff < 0).sum(), (diff > 0).sum()) / diff.size

    return cles


def rbc_ind(x1, x2):
    """Calculate rank-biserial correlation coefficient

    Output values range from [0, 1]; interpret as:
      * Values closer to 0 are a weaker effect
      * Values closer to 1 are a stronger effect

    :param x1: sample 1
    :param x2: sample 2
    :return: (float) rank-biserial correlation coefficient
    """
    n1 = x1.size
    n2 = x2.size

    u, _ = stats.mannwhitneyu(x1, x2)
    rbc = 1 - (2 * u) / (n1 * n2)

    return rbc


def calc_non_param_ci(x1, x2, alpha=0.05):
    """Calc confidence interval for 2 group median test

    Process:
      * Find all pairwise diffs
      * Sort diffs
      * Find appropriate value of k
      * Choose lower bound from diffs as: diffs[k]
      * Choose upper bound from diffs as: diffs[-k]

    Based on: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2545906/

    :param x1: sample 1
    :param x2: sample 2
    :param alpha: significance level
    :return: (tuple) confidence interval bounds
    """
    x1 = np.array(x1)
    x2 = np.array(x2)

    n1 = x1.size
    n2 = x2.size
    cv = stats.norm.ppf(1 - alpha / 2)

    # Find pairwise differences for every datapoint in each group
    diffs = (x1[:, None] - x2).flatten()
    diffs.sort()

    # For an approximate (1-a)% confidence interval first calculate K:
    k = int(round(n1 * n2 / 2 - (cv * (n1 * n2 * (n1 + n2 + 1) / 12) ** 0.5)))

    # The Kth smallest to the Kth largest of the n x m differences
    # n1 and n2 should be > ~20
    ci_lo = diffs[k]
    ci_hi = diffs[-k]

    return ci_lo, ci_hi


# ---------------------------
# Paired samples ------------
# ---------------------------
def cles_rel(x1, x2):
    """Calc common language effect size for paired samples

    Interpret as the probability that a pair's difference (x1 - x2)
    sampled at random will be greater than 0.

    :param x1: sample 1
    :param x2: sample 2
    :return: (float) common language effect size
    """
    x1 = np.array(x1)
    x2 = np.array(x2)

    diffs = x1 - x2
    # Convert differences to 0.0, 0.5, or 1.0:
    #   * 0.0 if x1 < x2
    #   * 0.5 if x1 == x2
    #   * 1.0 if x1 > x2
    diffs = np.where(diffs == 0.0, 0.5, diffs > 0)

    # Take average of array with [0s, 0.5s, 1s]
    # This indicates prob of pulling a random
    # diff and it being greater than 0
    return diffs.mean()


def rbc_rel(x1, x2):
    """Calculate rank-biserial correlation coefficient for paired samples

    Output values range from [-1, 1]; interpret as:
      * Values closer to 1 indicate that x1 is larger
      * Values closer to -1 indicate that x2 is larger

    :param x1: sample 1
    :param x2: sample 2
    :return: (float) rank-biserial correlation coefficient
    """
    x1 = np.array(x1)
    x2 = np.array(x2)

    diffs = x1 - x2
    diffs = diffs[diffs != 0]
    diff_ranks = stats.rankdata(abs(diffs))

    rank_sum = diff_ranks.sum()
    pos_rank_sum = np.sum((diffs > 0) * diff_ranks)
    neg_rank_sum = np.sum((diffs < 0) * diff_ranks)
    rbc = pos_rank_sum / rank_sum - neg_rank_sum / rank_sum

    return rbc
