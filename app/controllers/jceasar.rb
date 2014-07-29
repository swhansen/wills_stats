class Parse_Will_S

  def initialize
    require 'nokogiri'
    require 'open-uri'
  end

  def get_play
    @doc = Nokogiri::XML(File.open('js.xml'))
  end

  def get_title
    title = @doc.xpath("PLAY/TITLE").text
  end

  def get_personas
    #  Get the unique speakers from the actual Play NOT Personas tag
    # note: derived from crawling the speaker/line tags
    #          this produceds a slightly differant list than the Persona tags
    personas = @doc.xpath("//SPEECH/SPEAKER").to_s.gsub("<SPEAKER>" , '').gsub("</SPEAKER>" , ',').split(",")
    personas =  personas.uniq.sort_by{|word| word.downcase}
    personas -= %w{All}   #remove the All "Persona" per the req.
  end

  def get_number_of_lines
    number_of_lines = @doc.xpath("//LINE").count
  end

  def get_words_for_personas personas
    words_for_personas = {}
    personas.each do |speaker|
      total_words_for_persona = 0
      total_words_for_persona = @doc.xpath("//SPEECH[SPEAKER = '#{speaker}']/LINE").to_s.gsub("<LINE>", "").gsub("</LINE>", "").split(/[^-a-zA-Z]/).each.size
      words_for_personas[speaker] = total_words_for_persona
    end
    words_for_personas
  end

  def get_lines_for_personas personas
    lines_for_personas = {}
    personas.each do |speaker|
      total_lines_for_persona = 0
      total_lines_for_persona = @doc.xpath("//SPEECH[SPEAKER = '#{speaker}']/LINE").size
      lines_for_personas[speaker] = total_lines_for_persona
    end
    lines_for_personas
  end

  def get_longest_speech_for_personas personas
    longest_speech_for_personas = {}
    personas.each do |speaker|
      longest_speech_for_persona = 0
      @doc.xpath("//SPEECH[SPEAKER = '#{speaker}']").each do |node|
        node.text.gsub('#{speaker}','')
        speech_length = node.text.split.size
        if speech_length > longest_speech_for_persona
          longest_speech_for_persona = speech_length
        end
      end
      longest_speech_for_personas[speaker] = longest_speech_for_persona
    end
    longest_speech_for_personas
  end

  def get_number_of_scenes_for_personas personas
    number_of_scenes_for_personas ={}
    personas.each do |speaker|
      number_of_scenes_for_persona = 0
      @doc.xpath('//SCENE').each do |node|
        if node.text.include?  "#{speaker}" then
          number_of_scenes_for_persona+= 1
        end
      end
      number_of_scenes_for_personas[speaker] = number_of_scenes_for_persona
    end
    number_of_scenes_for_personas
  end

  def get_percent_of_scenes_for_personas personas
    number_of_scenes_in_play = @doc.xpath("//SCENE").count
    percent_of_scenes_for_personas = {}
    personas.each do |speaker|
      # Number of scenes appeared in for Persona
      number_of_scenes_for_persona = 0
      number_of_scenes_for_play= 0
      @doc.xpath('//SCENE').each do |node|
        number_of_scenes_for_play+= 1
        if node.text.include?  "#{speaker}" then
          number_of_scenes_for_persona += 1
          #puts number_of_scenes_for_persona
        end
      end
      percent_of_scenes_for_personas[speaker] = ((number_of_scenes_for_persona.to_f / number_of_scenes_in_play.to_f)*100).ceil
    end
    percent_of_scenes_for_personas
  end

  def get_number_scenes_in_play
    @doc.xpath("//SCENE").count
  end

end

play  = Parse_Will_S.new

play.get_play

title = play.get_title
puts "Title: #{title}"

actors = play.get_personas
puts "Actors: #{actors}"

lines = play.get_number_of_lines
puts "Total Lines: #{lines}"

total_words = play.get_words_for_personas actors
puts "Total Words #{total_words}"

longest = play.get_longest_speech_for_personas actors
puts "Longest Speech: #{longest}"

number_of_scenes = play.get_number_of_scenes_for_personas actors
puts "Number of Scenes: #{number_of_scenes}"

number_of_lines = play.get_lines_for_personas  actors
puts "Number of lines: #{number_of_lines}"

number_of_scenes = play.get_number_scenes_in_play
puts "Number of Scenes: #{number_of_scenes}"

percent_of_scenes = play.get_percent_of_scenes_for_personas actors
puts "Percent of Scenes #{percent_of_scenes}"
