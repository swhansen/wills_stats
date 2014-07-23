
###Basic Rails demo app to derive statistics from a  Shakespeare play XLM document and render it in sortable table that requires no page refresh

[Link to Julius Caesar play XML](https://gist.github.com/cmpowell/3fe19868b0a311c93386#file-julius_caesar-xml)

   * Produces an array of the following statistics for each Persona(speaker)
   * Generates an HTML table with "table id="jceasar_stats"

### Statistics Generated
- Number of lines  spoken by persona
- Longest speech in words by persona
- Number of Scenes Persona appears in
-  Percentage of total scense Persona appears in

### Notes:
- Persona list derived from "walking" the speaker list looking for unique Personas
- There is a slight differance than those from the PERSONA tag
- The "All" persona has been removed per the req.
- Generated HTML table has no styling and table id=jceasar_stats
