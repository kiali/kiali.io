---
title: "Performance and Scalability"
description: "Questions about Kiali Performance measurements and improvements."
---

### What performance and scalability measurements are done?

Performance tests were conducted on setups with **10**, **50**, **200**, **300**, **500**, and **800** namespaces. Each namespace contained:

- 1 Service
- 2 Workloads
- 2 Istio configurations


### What improvements have been made to Kiali's performance in recent versions?

The performance data was collected using automated performance tests on various setups, ensuring a comprehensive evaluation of improvements.
Since the release of Kiali v1.79, significant performance enhancements have been implemented, resulting in up to a **5x improvement** in page load times. 
The performance improvements were achieved by reducing the number of requests made from the Kiali UI to the services. Instead of multiple requests, the process was streamlined to unify these into a single request per cluster.
The enhanced performance significantly reduces the time users spend waiting for pages to load, leading to a more efficient and smooth user experience.

### What are the implications of these performance improvements?

These improvements make Kiali more responsive and efficient, particularly in environments with a large number of namespaces, services, and workloads, enhancing usability and productivity.

For a graphical representation of the performance measurements for the Overview page load times, refer to the chart below:

![Kiali Overview Page](/images/documentation/faq/performance/kiali-perf-overview-load-time.png)
