# DocPad Configuration File
# http://docpad.org/docs/config

# Define the DocPad Configuration
docpadConfig = {
  regenerateDelay: 100
  templateData:
    site:
      title: "My Gato Website"
    getPreparedTitle: -> if @document.title then "#{@document.title} | #{@site.title}" else @site.title
    underscore: require('underscore')

    # includeFileUrls will include all files in a folder and will return an array containing their urls
    # @param folder [String] the folder for which to load the files from
    # @param prependedFiles [Array] files from the folder to put first
    # @param appendedFiles [Array] files from the folder to put last
    # @param excludedFiles [Array] files from the folder to not to include
    # @param options [Object] you can choose:
    # - fingerprint: <true|false> fingerprint the files and use the fingerprinted url
    includeFileUrls: (folder, prependedFiles, appendedFiles, excludedFiles, options) ->
      prependedFiles = prependedFiles || []
      appendedFiles = appendedFiles || []
      excludedFiles = excludedFiles || []
      options = options || {}

      # 'merge' options with defaults
      options = @underscore.defaults(options, { fingerprint: true } );

      # url aggregator
      urls = []

      # Query excluded files are the ones that do not go 'in the middle'
      # from the ones that go 'in the middle'
      queryExcludedFiles = []

      # Transform all exluded files from folder to absolute paths
      for file in prependedFiles.concat(appendedFiles).concat(excludedFiles)
        queryExcludedFiles.push("/#{folder}/#{file}")

      # Get all file urls/paths but only put into "files" those that are not overriden
      # by orderedFiles
      for file in @getFilesAtPath(folder).toJSON()
        urls.push(file.url) if (queryExcludedFiles.indexOf(file.url) < 0 )

      # Prepend the specified files and tranform their relative path to absolute
      for filename in prependedFiles.reverse() #reverse so that unshift puts first one as first correctly
        urls.unshift("/#{folder}/#{filename}")

      # Prepend the specified files and tranform their relative path to absolute
      for filename in appendedFiles
        urls.push("/#{folder}/#{filename}")

      finalUrls = []

      if options['fingerprint'] == true
        for url in urls
          finalUrls.push(@asset(url))
      else
        finalUrls = urls

      finalUrls

    includeJS: (folder, prependedFiles, appendedFiles, excludedFiles, options) ->

      options = options || {}
      # 'merge' options with defaults
      options = @underscore.defaults(options, { onlyUrls: false } );
      urls = @includeFileUrls(folder, prependedFiles, appendedFiles, excludedFiles, options)

      if options['onlyUrls']
        urls
      else
        tags = []
        for url in urls
          tags.push("<script src='#{url}'></script>")

        # join the tags
        tags.join("\n")

    includeCSS: (folder, prependedFiles, appendedFiles, excludedFiles, options) ->

      options = options || {}
      # 'merge' options with defaults
      options = @underscore.defaults(options, { onlyUrls: false } );
      urls = @includeFileUrls(folder, prependedFiles, appendedFiles, excludedFiles, options)

      if options['onlyUrls']
        urls
      else
        tags = []
        for url in urls
          tags.push("<link rel='stylesheet' href='#{url}' />")

        # join the tags
        tags.join("\n")

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
