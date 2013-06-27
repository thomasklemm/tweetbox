# Statuses

# Preview new status
@StatusController = ($scope) ->
  $scope.statusCharCount = ->
    twttr.txt.getTweetLength(@statusText)

  $scope.previewCharCount = ->
    twttr.txt.getTweetLength(@previewText)

  $scope.virtualCharCount = ->
    twttr.txt.getTweetLength(@virtualText)

  $scope.updatePreview = ->
    @virtualText = @statusText

    if @virtualCharCount() <= 140
      @previewText = @virtualText
    else
      while @virtualCharCount() > 114
        @virtualText = @virtualText.substr(0, @virtualText.length - 1)

      @previewText = @virtualText + "...\nhttp://tweetbox.com/read-more"

  $scope.reply = ->
    @statusText[0] == '@'
