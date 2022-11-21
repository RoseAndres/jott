require "fileutils"
require "singleton"

class FileManager
  include Singleton

  def create_new_note(workbook_name, note_name)
    FileUtils.touch(path_to_note(workbook_name, note_name))
  end

  def create_new_workbook(workbook_name)
    FileUtils.mkdir_p(path_to_workbook(workbook_name))
  end

  def get_all_notes_for_workbook(workbook_name)
    Dir.glob(File.join(path_to_workbook(workbook_name), "*.txt")).
      select { |p| File.file?(p) }
  end

  def get_all_workbooks
    Dir.glob(File.join(base_path, "**")).
      select { |p| File.directory?(p) }
  end

  def get_note_contents(workbook_name, note_name)
    File.open(path_to_note(workbook_name, note_name)).read
  end

  def write_to_note(workbook_name, note_name, text)
    File.write(path_to_note(workbook_name, note_name), text)
  end

  private

  def base_path
    File.expand_path("~/jott")
  end

  def path_to_workbook(workbook_name)
    File.expand_path(workbook_name, base_path)
  end

  def path_to_note(workbook_name, note_name)
    File.expand_path("#{note_name}.txt", path_to_workbook(workbook_name))
  end
end
