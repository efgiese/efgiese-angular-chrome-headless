# efgiese-angular-chrome-headless

Docker image with embedded Node 12 and Chrome Headless preconfigured for Angular unit/e2e tests in CI/CD environments

## Get the image

```bash
docker pull efgiese/efgiese-angular-chrome-headless
```

## Karma config

```js
// Karma configuration file, see link for more information
// https://karma-runner.github.io/1.0/config/configuration-file.html

module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('karma-coverage-istanbul-reporter'),
      require('@angular-devkit/build-angular/plugins/karma')
    ],
    client: {
      clearContext: false // leave Jasmine Spec Runner output visible in browser
    },
    coverageIstanbulReporter: {
      dir: require('path').join(__dirname, '../coverage'),
      reports: ['html', 'lcovonly', 'text-summary'],
      fixWebpackSourcePaths: true,
      thresholds: {
        emitWarning: true, // set to `true` to not fail the test command when thresholds are not met
        global: { // thresholds for all files
          statements: 70,
          lines: 70,
          branches: 70,
          functions: 70
        }
      }
    },
    reporters: ['progress', 'kjhtml'],
    port: 9876,
    colors: true,
    logLevel: config.LOG_INFO,
    autoWatch: true,
    singleRun: false,
    browsers: ['Chrome, ChromeHeadless'],
    customLaunchers: {
      ChromeHeadless: {
        base: 'Chrome',
        flags: [
          '--headless',
          '--disable-gpu',
          '--no-sandbox',
          '--remote-debugging-port=9222'
        ]
      }
    }
  });
};
```

## Protractor config

```js
// Protractor configuration file, see link for more information
// https://github.com/angular/protractor/blob/master/lib/config.ts

const { SpecReporter } = require('jasmine-spec-reporter');

exports.config = {
  allScriptsTimeout: 11000,
  specs: [
    './src/**/*.e2e-spec.ts'
  ],
  capabilities: {
    'browserName': 'chrome',
    'chromeOptions': {
      'args': [
        '--no-sandbox',
        '--headless',
        '--disable-gpu',
        '--window-size=800,600'
      ]
    }
  },
  directConnect: true,
  baseUrl: 'http://localhost:4200/',
  framework: 'jasmine',
  jasmineNodeOpts: {
    showColors: true,
    defaultTimeoutInterval: 30000,
    print: function () { }
  },
  onPrepare() {
    require('ts-node').register({
      project: require('path').join(__dirname, './tsconfig.e2e.json')
    });
    jasmine.getEnv().addReporter(new SpecReporter({ spec: { displayStacktrace: true } }));
  }
};
```

## .gitlab-ci.yml

```yaml
image: efgiese/efgiese-angular-chrome-headless

cache:
  paths:
  - node_modules/

stages:
  - setup
  - test
  - build
  - deploy

setup:
  stage: setup
  script:
    - npm prune
    - npm install

lint:
  stage: test
  script:
    - ./node_modules/@angular/cli/bin/ng lint

test_e2e:
  stage: test
  script:
    - ./node_modules/@angular/cli/bin/ng e2e

test_karma:
  stage: test
  script:
    - ./node_modules/@angular/cli/bin/ng test --browsers ChromeHeadless --watch=false --code-coverage --source-map

build:
  stage: build
  script:
    - ./node_modules/@angular/cli/bin/ng build

deploy_staging:
  stage: deploy
  script:
    - ./node_modules/@angular/cli/bin/ng build --prod
    - cd dist
    - ls
    - sshpass -V
  environment:
    name: staging
  when: manual

deploy_prod:
  stage: deploy
  script:
    - ./node_modules/@angular/cli/bin/ng build --prod
    - cd dist
    - ls
    - sshpass -V
  environment:
    name: production
  when: manual
  only:
  - master
```

## Update

* Support Chrome 87
* Nodejs 14.15.1
