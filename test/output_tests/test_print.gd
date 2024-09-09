# ------------------------------------------------------------------------------
# These tests are used to test the output generated by parameterized
# tests.  These are only for visually verifying output formatting.
# ------------------------------------------------------------------------------
extends "res://addons/gut/test.gd"

var _old_indent_string = ''
var _orig_err_as_fail = false

func before_all():
	gut.p('[before all]')
	_old_indent_string = gut.logger.get_indent_string()
	_orig_err_as_fail = gut.treat_error_as_failure

	gut.treat_error_as_failure = false

func after_all():
	gut.p('[after all]')
	gut.logger.set_indent_string(_old_indent_string)
	gut.treat_error_as_failure = _orig_err_as_fail

func before_each():
	gut.p('[before each]')

func after_each():
	gut.p('[after each]')


func test_print_non_strings():
	gut.p([1, 2, 3])
	var n2d = Node2D.new()
	gut.p(n2d)
	n2d.free()
	pass_test('check output')

func test_print_multiple_lines():
	var lines = "hello\nworld\nhow\nare\nyou?"
	gut.p(lines)
	pass_test('check output')

func test_no_parameters():
	assert_true(true, 'this passes')

func test_multiple_passing_no_params():
	assert_true(true, 'passing test one')
	gut.p('something')
	assert_false(false, 'passing test two')

func test_multiple_failing_no_params():
	assert_false(true, 'SHOULD FAIL')
	assert_true(false, 'SHOULD FAIL')

func test_basic_array(p=use_parameters([1, 2, 1, 4])):
	assert_eq(p, 1, '2 and 4 expected to equal 1 SHOULD FAIL')

func test_all_passing(p=use_parameters([[1, 2], [3, 4], [5, 6]])):
	assert_eq(p[0], p[1 -1], 'output test, should all pass.')

func test_show_error():
	_lgr.error('Something bad happened')
	pass_test('look at error')

func test_show_warning():
	_lgr.warn('Something kinda bad happened')
	assert_true(true)

func test_show_info():
	_lgr.info('Something happened')
	assert_true(true)

func test_await():
	gut.p('starting awaiting')
	await wait_seconds(2)
	gut.p('end await')
	pass_test('check output')


class TestGuiOutput:
	extends GutTest

	var _gui = null
	var _logger = null

	func before_each():
		_gui = add_child_autofree(GutUtils.GutScene.instantiate())
		_logger = GutUtils.Logger.new()
		_logger._printers.gui = GutUtils.Printers.GutGuiPrinter.new()
		_logger.disable_printer('gui', false)
		var printer = _logger.get_printer('gui')
		printer.set_textbox(_gui.get_textbox())


	func test_embedded_bbcode():
		_logger.log('[u]this should not be underlined')
		await wait_frames(10)
		# assert_string_contains(_gui.get_textbox().text, '[u]this should')
		pass_test('Check output, cannot get bbcode out of RTL')
		pause_before_teardown()

	func test_embedded_bbcode_with_format():
		_logger.log('[i]this should not be italic but should be yellow', _logger.fmts.yellow)
		# assert_string_contains(_gui.get_textbox().text, '[i]this should')
		pass_test('Check output, cannot get bbcode out of RTL')
		pause_before_teardown()


	func test_embedded_bbcode_with_closing_tag():
		_logger.log('all of this [/b] should be bold', _logger.fmts.bold)
		_logger.log('this should not be bold')
		# assert_string_contains(_gui.get_textbox().text, '[/b] should be bold')
		pass_test('Check output, cannot get bbcode out of RTL')
		pause_before_teardown()



class TestBasicLoggerOutput:
	extends GutInternalTester

	var _test_logger = null
	func before_each():
		_test_logger = GutUtils.Logger.new()
		_test_logger.set_gut(gut)
		_test_logger.set_indent_string('|...')

	func test_indent_levels():
		_test_logger.log('0 indent')
		_test_logger.inc_indent()
		_test_logger.log('1 indent')
		_test_logger.inc_indent()
		_test_logger.inc_indent()
		_test_logger.log('3 indents')
		_test_logger.set_indent_level(1)
		_test_logger.log('1 indent')
		_test_logger.set_indent_level(10)
		_test_logger.log('10 indents')
		assert_true(true)

	func test_indent_with_new_lines():
		_test_logger.set_indent_level(2)
		_test_logger.log("hello\nthis\nshould\nline up")
		assert_true(true)


class TestLogLevels:
	extends GutTest # this was on purpose

	var _orig_log_level = -1
	var _orig_indent_string = null
	var _orig_err_as_fail = false

	func before_all():
		_orig_log_level = gut.log_level
		_orig_indent_string = gut.logger.get_indent_string()
		_orig_err_as_fail = gut.treat_error_as_failure

		gut.treat_error_as_failure = false
		gut.logger.set_indent_string('--->')


	func after_all():
		gut.log_level = _orig_log_level
		gut.logger.set_indent_string(_orig_indent_string)
		gut.treat_error_as_failure = _orig_err_as_fail

	func test_log_types_at_levels_with_passing_test(level=use_parameters([-2, -1, 0, 1, 2, 3])):
		gut.log_level = level
		gut.logger.warn('test text')
		gut.logger.error('test text')
		gut.logger.info('test text')
		gut.logger.debug('test text')
		assert_true(true, 'this should pass')

	func test_log_types_at_levels_with_failing_test(level=use_parameters([-2, -1, 0, 1, 2, 3])):
		gut.log_level = level
		gut.logger.warn('test text')
		gut.logger.error('test text')
		gut.logger.info('test text')
		gut.logger.debug('test text')
		assert_true(false, str('SHOULD FAIL (', level, ')'))