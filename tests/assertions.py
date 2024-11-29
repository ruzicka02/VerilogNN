import utils


def assert_addition(a, b, result):
    expected = a + b
    tolerance = max(utils.get_tolerance(a), utils.get_tolerance(b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} + {b} = {result} (expected {expected})"


def assert_multiplication(a, b, result):
    expected = a * b
    tolerance = utils.get_tolerance(a * b)

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {a} * {b} = {result} (expected {expected})"


def assert_divsion(a, b, result):
    expected = a / b
    # not sure whether this is the right level
    tolerance = max(
        utils.get_tolerance(a),
        utils.get_tolerance(b),
        utils.get_tolerance(a / b))

    assert abs(result - expected) < tolerance, \
        f"Mismatch: {
            a} / {b} = {result} (expected {expected}, tolerance: {tolerance})"
