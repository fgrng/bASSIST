# coding: utf-8
module ApplicationHelper

  # Navigation
  def shorten_name(string)
    string = string[0..30] + "…" if string.length > 30
    return string
  end

end
