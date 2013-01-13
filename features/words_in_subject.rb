require_relative 'feature'
require_relative '../lib/enum_stats'

class WordsInSubject < Feature
  self.table_name = "words_in_subject"

  def self.reset
    WordsInSubject.delete_all
    reset_counter(self.table_name)
  end

  def self.recalc
    mailbox_names.each do |mailbox|
      max, min, total_emails, total_words = 0, 99999999, 0, 0
      words_array = []

      emails_by_mailbox(mailbox) do |email|
        next unless email.subject
        subject_a = email.subject.split(/s+/).map(&:downcase)
        words_array << subject_a
        length = subject_a.size

        total_emails += 1
        total_words += length
        max = length if length > max
        min = length if length < min
      end

      words_length_a = words_array.flatten.map(&:size)
      WordsInSubject.create(
        :mailbox => mailbox,
        :total_emails => total_emails,
        :total_words => total_words,
        :total_uniq_words => words_array.uniq.count,
        :min => min,
        :max => max,
        :average => (words_length_a.empty? ? [0] : words_length_a).average,
        :std_dev => (words_length_a.empty? ? [0] : words_length_a).std_dev
      )
    end
  end
end
