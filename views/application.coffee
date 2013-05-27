###
methods related to the polling UI
###
@refreshUIFromServer = ->
  $.get('/data', (response) ->
    drawEmojiStats(response)
  , "json")

drawEmojiStats = (stats) ->
  selector = $("#data")
  selector.empty()
  for emoji_char in stats
    do (emoji_char) ->
      selector.append "
        <a href='/details/#{emoji_char.id}'>
        <li class='emoji_char' id='#{emoji_char.id}'>
          <span class='char'>#{emoji.replace_unified(emoji_char.char)}</span>
          <span class='score'>#{emoji_char.score}</span>
        </li>
        </a>"

###
methods related to the streaming UI
###
@startScoreStreaming = ->
  @source = new EventSource('/subscribe')
  # @source.addEventListener('stream.score_updates', processScoreUpdate, false)
  @source.onmessage = (event) -> incrementScore(event.data)

@stopScoreStreaming = ->
  @source.close()

@startDetailStreaming = (id) ->
  console.log "Subscribing to detail stream for #{id}"
  @detail_source = new EventSource("/subscribe/details/#{id}")
  @detail_source.addEventListener("stream.tweet_updates.#{id}", processDetailTweetUpdate, false)

@stopDetailStreaming = ->
  @detail_source.close()

processDetailTweetUpdate = (event) ->
  console.log event.data
  appendTweetList $.parseJSON(event.data)


###
index page UI helpers
###
incrementScore = (id) ->
  score_selector = $("li\##{id} > .score")
  container_selector = $("li\##{id}")

  count = parseInt score_selector.text()

  iOS = if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) then true else false
  jquery_animation = !iOS
  if jquery_animation
    score_selector.stop(true)
    container_selector.stop(true)
    score_selector.css 'color', 'red'
    container_selector.css 'background-color', 'lightgreen'
  score_selector.text ++count
  if jquery_animation
    score_selector.animate( {'color': 'black'}, 1000 )
    container_selector.animate( {'background-color': '#eee'}, 1000 )

###
detail page UI helpers
###
@appendTweetList = (tweet) ->
  tweet_list = $('ul#tweet_list')
  tweet_list_elements = $("ul#tweet_list li")
  tweet_list_elements.last().remove() if tweet_list_elements.size() >= 20
  tweet_list.prepend( formattedTweet tweet  )

###
general purpose UI helpers
###
formattedTweet = (tweet) ->
  tweet_url = "http://twitter.com/#{tweet.username}/status/#{tweet.id}"
  "<li><strong>@#{tweet.username}:</strong> #{tweet.text} <a href='#{tweet_url}'>\#</a></li>"

###
Polling
###
@startRefreshTimer = ->
  @refreshTimer = setInterval refreshUIFromServer, 3000

@stopRefreshTimer = ->
  clearInterval(@refreshTimer)

$ ->
  emoji.img_path = "http://unicodey.com/js-emoji/emoji/"
