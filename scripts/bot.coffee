# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

IS_AUTO = 'XIAOYI_ROOM_IS_AUTO_'

module.exports = (robot) ->

  robot.hear /.*/i, (res) ->
    text = res.match[0].replace('hubot-bearychat ', '')
    ROOM_KEY = IS_AUTO + res.message.room.vchannelId
    roomSwitch = robot.brain.get(ROOM_KEY)
    console.log('---------------message----------------\n', res.message, res.message.user.message.text, res.message.room.vchannelId, ROOM_KEY, roomSwitch)

    if (/小译开门|xiaoyi fire|xiaoyifire|xiaoyi open|xiaoyiopen/.test(text))
      robot.brain.set(ROOM_KEY, true)
      res.send('小译开启全自动翻译，火力全开！若想关闭，请说【小译关门】。\n' +
        'Xiaoyi, FIRE! Auto translator starts working! To mute, please tell me【xiaoyi mute】.')
      return
    else if (/小译关门|xiaoyi mute|xiaoyimute|xiaoyi close|xiaoyiclose/.test(text))
      robot.brain.set(ROOM_KEY, false)
      res.send('小译不说话了。需要翻译单独一句话时，请@我。需要开启自动翻译，请说【小译开门】。\n' +
        'Xiaoyi, mute! If you want to translate only one sentence, pls @me. ' +
        'If you want to translate all conversations. please input【xiaoyi fire】.')
      return

    if roomSwitch == false
      if (/小译 (.*)|=bxc32/i).test(res.message.user.message.text)
        text = text.replace('小译 ', '')
        requestTranslator(res, text, true)
      return
    else
      requestTranslator(res, text)
      return

  # robot.respond /小译 (.*)/i, (res) ->
  #   text = res.match[1].replace('小译 ', '')
  #   requestTranslator(res, text)

  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

  robot.respond /open the (.*) doors/i, (res) ->
    doorType = res.match[1]
    if doorType is "pod bay"
      res.reply "I'm afraid I can't let you do that."
    else
      res.reply "Opening #{doorType} doors"

  robot.hear /I like pie/i, (res) ->
    res.emote "makes a freshly baked pie"

  lulz = ['lol', 'rofl', 'lmao']

  robot.respond /lulz/i, (res) ->
    res.send res.random lulz

  robot.topic (res) ->
    res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"

  #   if res?
  #     res.reply "DOES NOT COMPUTE"

  robot.respond /bitcoin price\s(in\s)?(.*)/i, (msg) ->
    currency = msg.match[2].trim().toUpperCase()
    bitcoinPrice(msg, currency)

  robot.respond /have a soda/i, (res) ->
    # Get number of sodas had (coerced to a number).
    sodasHad = robot.brain.get('totalSodas') * 1 or 0
    console.log('sodasHad:', sodasHad)

    if sodasHad > 4
      res.reply "I'm too fizzy.."

    else
      res.reply 'Sure!'

      robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'

requestTranslator = (res, text, reply) ->
    type = 'en2zh'
    lang = detectLang text
    if (lang == 'jp')
      type = 'ja2zh'
    else if (lang == 'zh')
      type = 'zh2en'

    data = JSON.stringify({
      detect: true,
      media: 'text',
      request_id: 'xiaoyi-hubot',
      source: text,
      trans_type: type,
    })
    console.log(text, type)

    res.http("https://api.interpreter.caiyunai.com/v1/translator")
      .headers('Content-Type': 'application/json', 'X-Authorization': 'token 7dh1on39pu68rt2eo5yx')
      .post(data) (err, response, body) ->
        if err
          console.error(err)
          res.send "translator error"
          return

        json = JSON.parse body
        if json.rc == 0
          target = json.target
          char = target[target.length - 1]
          if (char == '.' || char == ',' || char == '。')
            target = target.substr(0, target.length - 1).trim()
          if reply
            res.reply target
          else
            res.send target
        else
          console.error(json)
          res.send "translator error"

detectLang = (str) ->
    lang = 'en'
    zhStr = str.match(/[\u4e00-\u9fa5]/g) || []
    zhPer = zhStr.length / str.length
    jpReg = /[\u3020-\u303F]|[\u3040-\u309F]|[\u30A0-\u30FF]|[\u31F0-\u31FF]/g
    jpStr = str.match(jpReg) || []
    jpPer = jpStr.length / str.length

    if jpPer > 0.03
      lang = 'jp'
    else if zhPer >= 0.096
      lang = 'zh'

    return lang

isURL = (str) ->
  return !!str.match(/[-a-zA-Z0-9@:%_\+.~#?&//=]{2,256}\.[a-z]{2,4}\b(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?/gi)

