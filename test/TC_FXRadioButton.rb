require 'test/unit'
require 'testcase'
require 'fox16'

class TC_FXRadioButton < Fox::TestCase
  include Fox

  def setup
    super(self.class.name)
    @radioButton = FXRadioButton.new(mainWindow, "cbText")
  end

  def test_setCheck_TRUE
    @radioButton.check = Fox::TRUE
    assert_equal(Fox::TRUE, @radioButton.checkState)
    assert(@radioButton.checked?)
    assert(!@radioButton.unchecked?)
    assert(!@radioButton.maybe?)
  end

  def test_setCheck_FALSE
    @radioButton.check = Fox::FALSE
    assert_equal(Fox::FALSE, @radioButton.checkState)
    assert(!@radioButton.checked?)
    assert(@radioButton.unchecked?)
    assert(!@radioButton.maybe?)
  end

  def test_setCheck_MAYBE
    @radioButton.check = Fox::MAYBE
    assert_equal(Fox::MAYBE, @radioButton.checkState)
    assert(!@radioButton.checked?)
    assert(!@radioButton.unchecked?)
    assert(@radioButton.maybe?)
  end

  def test_setCheck_true
    @radioButton.check = true
    assert_equal(Fox::TRUE, @radioButton.checkState)
    assert(@radioButton.checked?)
    assert(!@radioButton.unchecked?)
    assert(!@radioButton.maybe?)
  end

  def test_setCheck_false
    @radioButton.check = false
    assert_equal(Fox::FALSE, @radioButton.checkState)
    assert(!@radioButton.checked?)
    assert(@radioButton.unchecked?)
    assert(!@radioButton.maybe?)
  end
end
