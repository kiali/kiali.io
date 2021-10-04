---
title: "Health"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 2
---

## Health

Colors in the graph represent the health of your service mesh. A node colored red or orange might need attention. The color of an edge between components represents the health of the requests between those components. The node shape indicates the type of component such as services, workloads, or apps.

The health of nodes and edges is refreshed automatically based on the user's preference. The graph can also be paused to examine a particular state, or replayed to re-examine a particular time period.

<a class="image-popup-fit-height" href="/images/documentation/features/graph-health-v1.22.0.png" title="Visualize the health of your mesh">
    <img src="/images/documentation/features/graph-health-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>
</br>

## Health Configuration

Kiali calculates health by combining the individual health of several indicators, such as pods and request traffic.  The _global health_ of a resource reflects the most severe health of its indicators.

### Health Indicators

The table below lists the current health indicators and whether the indicator supports custom configuration for its health calculation.

|Indicator        |Supports Configuration   |
|-----------------|---|
|Pod Status       |No   |
|Traffic Health   |Yes  |

### Icons and colors

Kiali use icons and colors to indicate the health of resources and associated request traffic.

<div style="display: flex;">
  <ul>
    <li>
      <img src="/images/documentation/health-configuration/no_health.png" style="width: 40px;height: 40px" /> No Health Information (NA)
    </li>
    <li>
      <img src="/images/documentation/health-configuration/healthy.png" style="width: 40px;height: 40px" /> Healthy
    </li>
    <li>
      <img src="/images/documentation/health-configuration/degraded.png" style="width: 40px;height: 40px" /> Degraded
    </li>
    <li>
      <img src="/images/documentation/health-configuration/failure.png" style="width: 40px;height: 40px" /> Failure
    </li>
  </ul>
</div>

### Default Values

#### Request Traffic

By default Kiali uses the traffic rate configuration shown below.  Application errors have minimal tolerance while client errors have a higher tolerance reflecting that some level of client errors is often normal (e.g. 404 Not Found):

* For _http_ protocol 4xx are client errors and 5xx codes are application errors.
* For _grpc_ protocol all 1-16 are errors (0 is success).

So, for example, if the rate of application errors is >= 0.1% kiali will show `Degraded` health and if > 10% will show `Failure` health.

```yaml
# ...
  health_config:
    rate:
      - namespace: ".*"
        kind: ".*"
        name: ".*"
        tolerance:
          - code: "^5\\d\\d$"
            direction: ".*"
            protocol: "http"
            degraded: 0
            failure: 10
          - code: "^4\\d\\d$"
            direction: ".*"
            protocol: "http"
            degraded: 10
            failure: 20
          - code: "^[1-9]$|^1[0-6]$"
            direction: ".*"
            protocol: "grpc"
            degraded: 0
            failure: 10
# ...
```

### Configuration

Custom health configuration is specified in the Kiali CR. To see the supported configuration syntax for `health_config` visit [Kiali CR](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml).

Kiali applies *the first matching rate configuration (namespace, kind, etc)* and calculates the status for each tolerance. The reported health will be the status with highest priority (see below).

<table>
<tr>
  <th style="width: 150px">Rate Option</th><th>Definition</th><th>Default</th>
<tr>
  <td>namespace</td><td>Matching Namespaces (regex)</td><td>.* (match all)</td>
</tr>
<tr>
  <td>kind</td><td>Matching Resource Types (workload|app|service) (regex)</td><td>.* (match all)</td>
</tr>
<tr>
  <td>name</td><td>Matching Resource Names (regex)</td><td>.* (match all)</td>
</tr>
<tr>
  <td>Tolerance</td><td>Array of tolerances to apply.</td>
</tr>
<tr>
    <table style="margin-left:40px">
      <tr>
        <th>Tolerance Option</th>
        <th>Definition</th>
        <th>Default</th>
      </tr>
      <tr>
        <td>code</td>
        <td>Matching Response Status Codes (regex) [1]</td>
        <td><strong>required</strong></td>
      </tr>
      <tr>
        <td>direction</td>
        <td>Matching Request Directions (inbound|outbound) (regex)</td>
        <td>.* (match all)</td>
      </tr>
      <tr>
        <td>protocol</td>
        <td>Matching Request Protocols (http|grpc) (regex)</td>
        <td>.* (match all)</td>
      </tr>
      <tr>
        <td>degraded</td>
        <td>Degraded Threshold(% matching requests >= value)</td>
        <td>0</td>
      </tr>
      <tr>
        <td>failure</td>
        <td>Failure Threshold (% matching requests >= value)</td>
        <td>0</td>
      </tr>
    </table>
</tr>
</table>

_[1] The status code typically depends on the request protocol. The special code **-**, a single dash, is used for requests that don't receive a response, and therefore no response code._

Kiali reports traffic health with the following top-down status priority :

 <table>
    <tr>
        <th>Priority</th>
        <th>Rule (value=% matching requests)</th>
        <th>Status</th>
    </tr>
    <tr>
      <td>1</td>
      <td>value >= FAILURE threshold</td>
      <td><img src="/images/documentation/health-configuration/failure.png" style="width: 40px;height: 40px" />FAILURE</td>
    </tr>
    <tr>
      <td>2</td>
      <td>value >= DEGRADED threshold AND value < FAILURE threshold</td>
      <td><img src="/images/documentation/health-configuration/degraded.png" style="width: 40px;height: 40px" />DEGRADED</td>
    </tr>
    <tr>
      <td>3</td>
      <td>value > 0 AND value < DEGRADED threshold</td>
      <td><img src="/images/documentation/health-configuration/healthy.png" style="width: 40px;height: 40px" />HEALTHY</td>
    </tr>
    <tr>
      <td>4</td>
      <td>value = 0</td>
      <td><img src="/images/documentation/health-configuration/healthy.png" style="width: 40px;height: 40px" />HEALTHY</td>
    </tr>
    <tr>
      <td>5</td>
      <td>No traffic</td>
      <td><img src="/images/documentation/health-configuration/no_health.png" style="width: 40px;height: 40px" />No Health Information</td>
    </tr>

 </table>

## Examples

These examples use the repo _https://github.com/kiali/demos/tree/master/error-rates_.

In this repo we can see 2 namespaces: alpha and beta ([Demo design](https://github.com/kiali/demos/tree/master/error-rates#error-rates-demo-design)).

<table>
<tr style="text-align: center">
<td>Alpha</td>
</tr>
<tr style="text-align: center">
<td>
<img src="https://raw.githubusercontent.com/kiali/demos/master/error-rates/doc/Kiali-AlphaNamespace.png" style="width: 80%; height: 60%" />
</td>
</tr>
</table>


Where nodes return the responses (You can configure responses [here](https://github.com/kiali/demos/tree/master/error-rates#configurable-error-rates)):

- [Alpha deployment](https://github.com/kiali/demos/blob/master/error-rates/alpha.yaml)
- [Beta deployment](https://github.com/kiali/demos/blob/master/error-rates/beta.yaml)

|App (alpha/beta)  |Code  |Rate   |
|------------------|------|-------|
|x-server          |200   |9   |
|x-server          |404   |1   |
|y-server          |200   |9   |
|y-server          |500   |1   |
|z-server          |200   |8   |
|z-server          |201   |1   |
|z-server          |201   |1   |

<br/>
The applied traffic rate configuration is:

```yaml
# ...
health_config:
  rate:
   - namespace: "alpha"
     tolerance:
       - code: "404"
         failure: 10
         protocol: "http"
       - code: "[45]\\d[^\\D4]"
         protocol: "http"
   - namespace: "beta"
     tolerance:
       - code: "[4]\\d\\d"
         degraded: 30
         failure: 40
         protocol: "http"
       - code: "[5]\\d\\d"
         protocol: "http"
# ...
```

After Kiali adds default configuration we have the following (Debug Info Kiali):

```json
{
  "healthConfig": {
    "rate": [
      {
        "namespace": "/alpha/",
        "kind": "/.*/",
        "name": "/.*/",
        "tolerance": [
          {
            "code": "/404/",
            "degraded": 0,
            "failure": 10,
            "protocol": "/http/",
            "direction": "/.*/"
          },
          {
            "code": "/[45]\\d[^\\D4]/",
            "degraded": 0,
            "failure": 0,
            "protocol": "/http/",
            "direction": "/.*/"
          }
        ]
      },
      {
        "namespace": "/beta/",
        "kind": "/.*/",
        "name": "/.*/",
        "tolerance": [
          {
            "code": "/[4]\\d\\d/",
            "degraded": 30,
            "failure": 40,
            "protocol": "/http/",
            "direction": "/.*/"
          },
          {
            "code": "/[5]\\d\\d/",
            "degraded": 0,
            "failure": 0,
            "protocol": "/http/",
            "direction": "/.*/"
          }
        ]
      },
      {
        "namespace": "/.*/",
        "kind": "/.*/",
        "name": "/.*/",
        "tolerance": [
          {
            "code": "/^5\\d\\d$/",
            "degraded": 0,
            "failure": 10,
            "protocol": "/http/",
            "direction": "/.*/"
          },
          {
            "code": "/^4\\d\\d$/",
            "degraded": 10,
            "failure": 20,
            "protocol": "/http/",
            "direction": "/.*/"
          },
          {
            "code": "/^[1-9]$|^1[0-6]$/",
            "degraded": 0,
            "failure": 10,
            "protocol": "/grpc/",
            "direction": "/.*/"
          }
        ]
      }
    ]
  }
}
```

What are we applying?

- For namespace alpha, all resources
- Protocol http if % requests with error code 404 are >= 10 then FAILURE, if they are > 0 then DEGRADED
- Protocol http if % requests with others error codes are> 0 then FAILURE.

- For namespace beta, all resources
- Protocol http if % requests with error code 4xx are >= 40 then FAILURE, if they are >= 30 then DEGRADED
- Protocol http if % requests with error code 5xx are > 0 then FAILURE

- For other namespaces kiali apply defaults.
- Protocol http if % requests with error code 5xx are >= 20 then FAILURE, if they are >= 0.1 then DEGRADED
- Protocol grpc if % requests with error code match /^[1-9]$|^1[0-6]$/ are >= 20 then FAILURE, if they are >= 0.1 then DEGRADED

 <table >
    <tr style="text-align: center">
        <td> Alpha </td>
        <td> Beta </td>
    </tr>
    <tr>
      <td><img src="/images/documentation/health-configuration/alpha.png" style="width: 100%;height: 800px" /></td>
      <td><img src="/images/documentation/health-configuration/beta.png" style="width: 100%;height: 800px" /></td>
    </tr>
 </table>

