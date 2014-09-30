class curry:
    def __init__(self, func, *args, **kwargs):
        self._func, self._params, self._pos = func, args, kwargs.get('pos', 0)
    def __call__(self, *args):
        return self._func(*(args[:self._pos] + self._params + args[self._pos:]))