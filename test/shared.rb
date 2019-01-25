# frozen_string_literal: true

TEST_DIRECTORY = 'test/results'
LOCO_URL = 'https://localise.biz/api/export/locale'
RES_DIR = 'test/res'

def _check_parsed(strings, plurals)
  assert_equal STRING_COUNT,
               strings.count,
               'Not the right amount of strings'

  assert_equal PLURAL_COUNT,
               plurals.count,
               'Not the right amount of plurals'

  assert_equal 'Around me',
               strings['around_me'],
               'Missing test strings'

  dic = { 'one' => "\%d Adult", 'other' => "\%d Adults" }
  assert_equal dic,
               plurals['adults'],
               'Wrong adults strings'
end
