const express = require('express');
const puppeteer = require('puppeteer');
const assert = require('assert');

var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
    SecretId: process.env["COS_KEY"],
    SecretKey: process.env["COS_SECRET"]
});

const bucket = 'bucket-cssg-test-js-1253653367'
const region = 'ap-guangzhou'

function setup(callback) {
    cos.putBucket({
        Bucket: bucket,
        Region: region
    }, function(err, data) {
        if (!err || err.statusCode == 409) {
            cos.putBucketCors({
                Bucket: bucket, /* 必须 */
                Region: region,    /* 必须 */
                CORSRules: [{
                    "AllowedOrigin": ["*"],
                    "AllowedMethod": ["GET", "POST", "PUT", "DELETE", "HEAD"],
                    "AllowedHeader": ["*"],
                    "ExposeHeader": ["ETag", "x-cos-acl", "x-cos-version-id", "x-cos-delete-marker", "x-cos-server-side-encryption"],
                    "MaxAgeSeconds": "600"
                }]
            }, callback);
        } else {
            callback(err, null)
        }
    });
}

function teardown(callback) {
    cos.deleteBucket({
        Bucket: bucket,
        Region: region
    }, callback);
}

var gBrowser
var server

function startServer(done) {
    var failCase = 0

    const serverPort = 4005
    // 启动静态服务器
    var app = express();
    app.use('/', express.static(__dirname));
    server = app.listen(serverPort, function() {
        console.log('SERVER start.')
    });

    puppeteer.launch({
        args: [
            '--no-proxy-server',
        ]
    }).then(function (browser) {
        gBrowser = browser
        setup((err, data) => {
            if (err) {
                console.error(err)
                done(err)
                return
            }
    
            browser.newPage().then(function (page) {
                page.on('console', function (msg) {
                    var text = msg.text();
                    var type = msg.type();
                    if (text === '[exit]') {
                        teardown((err, data) => {
                            console.log('TESTING ENDS.')
                            if (err) {
                                console.log(err);
                                done(err)
                            } else {
                                console.log(`RESULT: ${failCase} cases fails.`)
                                assert.equal(failCase, 0)
                                done();
                            }
                        })
                    } else {
                        if (type == 'log') {
                            console.log(`SUCCESS... ${msg.location().url}#${msg.location().lineNumber}`)
                        } else {
                            console.log(msg)
                            failCase++
                        }
                    }
                });
                page.goto(`http://127.0.0.1:${serverPort}/test/index.html`);
            })
        })
    });
}

describe("RunCOSTest", function() {
    it("puppeteer", function(done) {
        startServer(done);
    })
})

after(() => {
    gBrowser.close()
    console.log('SERVER end.')
    server.close()
})