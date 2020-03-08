from os import environ
from typing import Iterable, Optional, TypeVar, Callable
from re import compile

S = TypeVar('S', str, int, bool, float)

env_var_pattern = compile(r"^\$[a-zA-Z0-9_]+$")


def load_env(key: str,
             default: Optional[S] = None,
             essential=True,
             transform: Callable[[str], S] = lambda s: s,
             _visited=None) -> S:
    """
    Load an environment variable, following references to other env vars
    :param key:
    :param default: default value
    :param transform:
    :param essential: If env var is not found, whether or not to throw an exception
    :param _visited: previously visited env vars for cycle detection
    :return:
    """
    if _visited is None:
        _visited = []
    elif key in _visited:
        raise RuntimeError(f"Circular env references encountered: {_visited}")
    var = environ.get(key)
    if var is not None and env_var_pattern.match(var) is not None:
        # follow reference to other env vars
        return load_env(var[1:], default, _visited=[key] + _visited)

    if essential and var is default and default is None:
        raise RuntimeError(f"Essential variable ${key} is not present in environment and has no default")
    if var is not None:
        return transform(var)
    else:
        return default


def load_env_keys(keys: Iterable[str],
                  default: Optional[S] = None,
                  essential=True,
                  transform: Callable[[str], S] = lambda s: s) -> S:
    for key in keys:
        var = load_env(key, essential=False, transform=transform)
        if var is not None:
            return var
    if essential and default is None:
        raise RuntimeError(
            f"Essential variable searched for with keys ${keys} is not present in environment and has no default")
    return default


def parse_bool(s: str) -> bool:
    return s.lower() == "true"
