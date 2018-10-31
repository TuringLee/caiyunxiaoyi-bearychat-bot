# xiaoyi.coffee
#
# Authors: bitwater
# Date: 24/10/2018
# Desc:
# Copyright (c) 2018 caiyunapp.com. All rights reserved.
 
IS_AUTO = 'XIAOYI_ROOM_IS_AUTO_'
XIAOYI_API_TOKEN = process.env.XIAOYI_API_TOKEN

if !XIAOYI_API_TOKEN
  throw new Error('env variable XIAOYI_API_TOKEN is required')

module.exports = (robot) ->

  robot.hear /.*/i, (res) ->
    # text = res.match[0].replace('hubot-bearychat ', '')
    text = res.message.user.message.text
    ROOM_KEY = IS_AUTO + res.message.room.vchannelId
    roomSwitch = robot.brain.get(ROOM_KEY)
    console.log('---------------message----------------\n', res.message)

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

    if roomSwitch == true
      requestTranslator(res, text)
      return
    else
      if (/小译 (.*)|=bxc32/i).test(text)
        text = text.replace('小译 ', '')
        requestTranslator(res, text, true)
      return

  # robot.respond /小译 (.*)/i, (res) ->
  #   text = res.match[1].replace('小译 ', '')
  #   requestTranslator(res, text)

requestTranslator = (res, text, fromId, isReply) ->
    if isURL(text)
      reqShareHtml(res, text, '', isReply)
      return
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

    res.http("https://api.interpreter.caiyunai.com/v1/translator")
      .headers('Content-Type': 'application/json', 'X-Authorization': 'token ' + XIAOYI_API_TOKEN)
      .post(data) (err, response, body) ->
        if err
          console.error(err)
          res.send err.message
          return

        json = JSON.parse body
        if json.rc == 0
          target = json.target
          char = target[target.length - 1]
          if (char == '.' || char == ',' || char == '。')
            target = target.substr(0, target.length - 1).trim()
          if isReply
            res.reply target
          else
            res.send target
        else
          console.error(json)
          res.send body

reqShareHtml = (res, text, fromUserName, isReply) ->
  type = "en2zh"
  url = text.replace(/\n|\r|\t/, '')
  if (url.indexOf("http") < 0)
    url = "https://" + url
  console.log(url)
  data = JSON.stringify({
    "user_id": "5a096eec830f7876a48aac47",
    "browser_id": fromUserName,
    "url": url,
    "lang": "zh"
  })

  res.http("https://api-staging.interpreter.caiyunai.com/v1/page/read")
      .headers('Content-Type': 'application/json', 'X-Authorization': 'token ' + XIAOYI_API_TOKEN)
      .post(data) (err, response, body) ->
        if err
          console.error(err)
          res.send err.message
          return

        json = JSON.parse body
        console.log(json)
        if json.rc == 0
          article = json.article
          reMeg = "[#{article.title_target}](#{article.public_url})\n#{article.contentDesc}"
          if article.contentImg
            reMeg = reMeg + "\n![#{article.title}](#{article.contentImg})"
          if isReply
            res.reply reMeg
          else
            res.send(reMeg)
        else
          console.error(json)
          res.send body

  
        # rslv({
        #   title: share.title,
        #   description: share.description,
        #   picurl: share.icon_url,
        #   url: share.share_url
        # });
      
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

