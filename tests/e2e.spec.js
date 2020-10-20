/**
 * @jest-environment node
 */

const WebSocket = require('ws');
const https = require('https');
const querystring = require('querystring');

const postGif = (parameters) => {
  const queryParams = querystring.stringify(parameters);

  const options = {
    hostname: 'gifmachine.rmdp.tk',
    port: 443,
    path: '/gif?' + queryParams,
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }

  const req = https.request(options, res => {
    expect(res.statusCode).toBe(200);
  })

  req.end();
}

it('accept web socket connections and stream events', () => {
  // Open websocket connection with the gifmachine service
  const ws = new WebSocket('wss://gifmachine.rmdp.tk');

  // Test the message has the expected structure and count the times we receive an event and store the gif url
  ws.on('message', (e) => {
    let curr = JSON.parse(e);
    expect(curr).toHaveProperty('type', 'gif');
    expect(curr).toHaveProperty('url');
    expect(curr).toHaveProperty('meme_top');
    expect(curr).toHaveProperty('meme_bottom');
  });

  // Make a couple of requests to simulate users
  parametersOne = {
    url: 'https://media.giphy.com/media/A42JMXnXn4E7WQAAs/giphy.gif',
    who: "tester",
    meme_top: "first",
    meme_bottom: "first",
    secret: "too_secret_to_guess"
  };
  postGif(parametersOne);

  parametersTwo = {
    url: 'https://media.giphy.com/media/B43JMXnXn4E7WQBBs/giphy.gif',
    who: "tester",
    meme_top: "second",
    meme_bottom: "second",
    secret: "too_secret_to_guess"
  };
  setTimeout(() => postGif(parametersTwo), 2000);

  // Wait 5 seconds to complete the requests and receive the messages and close the socket
  setTimeout(() => ws.close(), 5000);
});

it('rject request with wrong password', () => {
  parameters = {
    url: 'https://media.giphy.com/media/B43JMXnXn4E7WQBBs/giphy.gif',
    who: "tester",
    meme_top: "second",
    meme_bottom: "second",
    secret: "too_wrong"
  };

  const queryParams = querystring.stringify(parameters);

  const options = {
    hostname: 'gifmachine.rmdp.tk',
    port: 443,
    path: '/gif?' + queryParams,
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }

  const req = https.request(options, res => {
    expect(res.statusCode).toBe(403);
  })

  req.end();
});
