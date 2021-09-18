import itertools


def grouper(iterable, n, fillvalue=None):
    """Collect data into fixed-length chunks or blocks
    https://docs.python.org/3/library/itertools.html
    """
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return itertools.zip_longest(*args, fillvalue=fillvalue)
