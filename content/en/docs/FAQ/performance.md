---
title: "Performance and Scalability"
description: "Questions about Kiali Performance measurements and improvements."
---

### What performance and scalability measurements are done?

Performance tests are conducted on setups with **10**, **50**, **200**, **300**, **500**, and **800** namespaces. Each namespace contains:

- 1 Service
- 2 Workloads
- 2 Istio configurations


### What improvements have been made to Kiali's performance in recent versions?

Performance data is collected using automated performance tests on various setups, ensuring a comprehensive evaluation of improvements.
Since the release of Kiali v1.80, significant performance enhancements have been implemented, resulting in up to a **5x improvement** in page load times. 
The performance improvements were achieved by reducing the number of requests made from the Kiali UI to the services. Instead of multiple requests, the process was streamlined to unify these into a single request per cluster.
The enhanced performance significantly reduces the time users spend waiting for pages to load, leading to a more efficient and smooth user experience.

**Performance Improvements Matrix Per Kiali Version And Section**

| <div style="width:100px">Kiali</div> | <div style="width:200px">Section</div> | Improvements                      |
| ------------------------------------ | -------------------------------------- | --------------------------------  |
| 1.80                                 | Graph Page                             | Validations                       |
| 1.81                                 | Overview Page                          | mTLS, Metrics, Health             |
| 1.82                                 | Applications List                      | Overall loading                   |
| 1.83                                 | Workloads List, Services List          | Overall loading                   |

<br />

These improvements make Kiali more responsive and efficient, particularly in environments with a large number of namespaces, services, and workloads, enhancing usability and productivity.

For a graphical representation of the performance measurements for the Overview page load times, refer to the chart below:

![Kiali Overview Page](/images/documentation/faq/performance/kiali-perf-overview-load-time.png)
