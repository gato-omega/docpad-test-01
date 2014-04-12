# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
  regenerateDelay: 100
  templateData:
    site:
      title: "My Gato Website"
    getPreparedTitle: -> if @document.title then "#{@document.title} | #{@site.title}" else @site.title
    importStylesheets: ->
      @getBlock("scripts").toHTML()
    # jsRequire tree will take a folder name as first argument
    # @param folder the folder for which to load the files from
    # @param prependedScripts scripts from the folder to put first
    # @param prependedScripts scripts from the folder to put last
    jsRequireTree: (folder, prependedScripts, appendedScripts) ->
      scripts = []
      prependedScripts = prependedScripts || []
      appendedScripts = appendedScripts || []

      excludedScripts = prependedScripts.concat appendedScripts

      # Get all script urls/paths but only put into "scripts" those that are not overriden
      # by orderedScripts
      for script in @getFilesAtPath(folder).toJSON()
        scripts.push(script.url) if (excludedScripts.indexOf(script.outFilename) < 0 )

      # Join the two arrays, scripts in order first
      scripts = prependedScripts.concat(scripts)
      scripts = scripts.concat(appendedScripts)

      fingerprintedScripts = []

      for script in scripts
       fingerprintedScripts.push(@asset(script))

      # Call the scripts block and add those urls
      @getBlock("scripts").add(fingerprintedScripts).toHTML()


  collections:
    pages: ->
      @getCollection('html').findAllLive({isPage:true},[{filename: 1}])

  plugins:
    assets:
      retainPath: 'yes'
      retainName: 'yes'

}

# Export the DocPad Configuration
module.exports = docpadConfig
