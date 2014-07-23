require 'nokogiri'
require 'open-uri'
#  Basic application to derive statistics from a  Shakespear play XLM document
#  XML location: https://gist.github.com/cmpowell/3fe19868b0a311c93386#file-julius_caesar-xml
#
#  - Produces an array of the following statistics for each Persona(speaker)
#  - Generates a HTML table with "table id="jceasar_stats"
#   Statistics Generated
#  -  Number of lines  spoken by persona
#  -  Longest speech in words by persona
#  -  Number of Scenes Persona appears in
#  -  Percentage of total scense Persona appears in
#
# Notes:
#  - Persona list derived from "walking" the speker list looking for unique Personas
#  - There is a slight differance than those from the PERSONA tag
#  - The "All" persona has been removed per the req.
#
def  stats_for_shakespear

  doc = Nokogiri::XML(File.open('js.xml'))

  #doc = Nokogiri::HTML(open("https://gist.github.com/cmpowell/3fe19868b0a311c93386#file-julius_caesar-xml"))
 
  stats_ary = []
  final_stats_ary = []

  #  Get the unique speakers from the actual Play NOT Personas tag
  # note: derived from crawling the speaker/line tags
  #          this produceds a slightly differant list than the Persona tags

  personas = doc.xpath("//SPEECH/SPEAKER").to_s
  personas = personas.gsub("<SPEAKER>" , '').gsub("</SPEAKER>" , ',').split(",")
  personas =  personas.uniq.sort_by{|word| word.downcase}
  personas -= %w{All}   #remove the All "Persona" per the req.

  # Total lines for each Persona

  personas.each do |speaker|
    total_lines_for_persona = doc.xpath("//SPEECH[SPEAKER = '#{speaker}']/LINE")
    total_lines_for_persona = total_lines_for_persona.to_s
    total_lines_for_persona = total_lines_for_persona.gsub("<LINE>", "").gsub("</LINE>", "").split(/[^-a-zA-Z]/).each.size

    #Longest Speech

    longest_speech_for_persona = 0

    doc.xpath("//SPEECH[SPEAKER= '#{speaker}']" ).each do |node|
      node.text.gsub('#{speaker}','')
      speech_length = node.text.split.size - 1

      if speech_length > longest_speech_for_persona
        longest_speech_for_persona = speech_length
      end
    end

    # Number of scenes appeared in for Persona

    number_of_scenes_for_persona = 0
    number_of_scenes_for_play= 0

    doc.xpath('//SCENE').each do |node|
      number_of_scenes_for_play+= 1
      if node.text.include?  "#{speaker}" then
        number_of_scenes_for_persona += 1
      end
    end

    # Percent of scenes for each persona

    percent_of_scenes_for_persona = ((number_of_scenes_for_persona.to_f / number_of_scenes_for_play.to_f) * 100).round
    
    # The final array

    stats_ary = ["#{speaker}",  "#{total_lines_for_persona}", "#{longest_speech_for_persona}","#{number_of_scenes_for_persona}", "#{percent_of_scenes_for_persona}" ]

    final_stats_ary.push(stats_ary)
  end
  #
  # Generate HTML table
  #
grouped = final_stats_ary.group_by{|t| t[0]}.values
table_head = %Q{<table id="jceasar_stats" } + %Q{class="display">}  +  "\n"  + "<thead>"+ "\n"
header = "<tr><th>Persona</th> <th>Lines Spoken</th> <th>Longest Speech </th> <th>Scenes In</th><th>Percent Scenes In</th> </tr>"
puts table_head
puts header
puts "</thead>"
table = grouped.map do |portion|
  "<tr>" << portion.map do |column|
     "<td>" << column.map do |element|
      element.to_s
    end.join("</td><td>") << "</td>"
  end.join("</tr>\n<tr>") << "</tr>"
end.join("\n")
puts table
puts "</table>"
end

stats_for_shakespear
