# Description:
#   Writes a counter to hubot brain & to Librato for graphing
#
# Configuration
#   HUBOT_LIBRATO_USER - Username
#   HUBOT_LIBRATO_RECORD_TOKEN - Writeable token value
#

module.exports = (robot) ->
    robot.on 'librato_write:gauge', (key, msg, count=1) ->

        url = 'https://metrics-api.librato.com/v1/metrics'
        user = process.env.HUBOT_LIBRATO_USER
        pass = process.env.HUBOT_LIBRATO_RECORD_TOKEN
        auth = 'Basic ' + new Buffer(user + ':' + pass).toString('base64');

        # Only needed for regular counters!
        # if not robot.brain.get(key)
        #     robot.brain.set(key, 0)
        # robot.brain.set(key, robot.brain.get(key) + 1)
        # value: robot.brain.get(key),

        metric = {}
        metric["gauges"] = {}
        metric["gauges"]["hubot.#{key}"] = { 
            value: count,
            source: "slack"
        }
        data = JSON.stringify(metric)

        robot.http(url)
            .headers(Authorization: auth, Accept: 'application/json')
            .post(data) (err, res, body) ->
                switch res.statusCode
                    when 200
                        null
                    when 401
                        console.log "Invalid login, please check your credentials!"
                    when 400
                        console.log "#{res.statusCode}: Source [#{data}] Response [#{body}]"
                    else
                        console.log "Unknown error happened: #{res.statusCode} -> Source [#{data}] Err [#{err}] Response [#{body}]"

