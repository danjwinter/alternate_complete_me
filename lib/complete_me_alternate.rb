class CompleteMe
  attr_accessor :root

  def initialize
    @root = Node.new("")
  end

  def insert(data)
    @root.insert(data)
  end

  def count
    @root.count
  end

  def suggest(prefix)
    @root.suggest(prefix)
  end

  def select(prefix, word)
    @root.select(prefix, word)
  end

  def choose(word)
    @root.choose(word)
  end

  def populate(source)
    arr = source.downcase.split("\n")
    arr.each do |entry|
      @root.insert(entry)
    end
    nil
  end

  def contain(prefix)
    @root.contain(prefix)
  end

  def find_prefix(prefix)
    @root.find_prefix(prefix)
  end
end

class Node
  attr_reader :links, :data
  attr_accessor :word_indicator, :rank, :ranking_hash

  def initialize(data)
    @data = data
    @links = {}
    @word_indicator = false
    @rank = 0
    @ranking_hash = {}
  end


  def insert(value, counter=0)
    ranking_hash.merge!({value => 0})
    if links[value[0..counter]].nil?
      links[value[0..counter]] = Node.new(value[0..counter])
    end
    if value[counter + 1].nil?
      links[value[0..counter]].word_indicator = true
      links[value[0..counter]].ranking_hash.merge!({value => 0})
    else
      links[value[0..counter]].insert(value, counter + 1)
    end
  end

  def count
    if data == "" && links.empty?
      0
    elsif links.empty?
      1
    elsif word_indicator == true
      1 + (links.values.map {|value| value.count}).reduce(&:+)
    else
      (links.values.map {|value| value.count}).reduce(&:+)
    end
  end

  def contain(prefix)
    new_arr = find_words_with_rank(prefix).map do |word_rank_pair|
      word_rank_pair[0]
    end
    new_arr
  end

  def find_words_with_rank(prefix, counter=0, contains_array=[])
    if word_indicator == true && data.include?(prefix)
        put_words_in_array(prefix, counter, contains_array)
    end
      unless links.nil?
        links.values.map {|value| value.find_words_with_rank(prefix, counter, contains_array)}
      end
    contains_array.uniq
  end

  def put_words_in_array(prefix, counter, contains_array)
    if contains_array.empty? || contains_array[counter].nil?
        contains_array << [self.data, self.rank]
    elsif rank > contains_array[counter][1]
        contains_array.insert(counter, [self.data, self.rank])
    else
      find_words_with_rank(prefix, counter + 1, contains_array)
    end
  end

  def find_prefix(prefix, counter=0)
    if data == prefix
      return self
    elsif data == prefix[0..counter]
      links[prefix[0..counter + 1]].find_prefix(prefix, counter + 1)
    else
      unless links[prefix[0..counter]].nil?
        links[prefix[0..counter]].find_prefix(prefix, counter)
      end
    end
  end

  def suggest(prefix)
    start = find_prefix(prefix)
    if start.ranking_hash.values.uniq == [0]
      new_arr = start.ranking_hash.sort
      final_arr = new_arr.map do |word_rank_pair|
        word_rank_pair[0]
      end
      final_arr.sort!
    else
      new_arr = start.ranking_hash.sort {|a, b| a[1] <=> b[1] }.reverse
      final_arr = new_arr.map do |word_rank_pair|
        word_rank_pair[0]
      end
      final_arr
    end
  end

  def select(prefix, word)
    node = find_prefix(prefix)
    node.ranking_hash[word] += 1
  end

  def choose(word)
    if data == word
      self.rank += 1
    elsif links != {}
      links.values.each {|value| value.choose(word)}
    end
    nil
  end
end
