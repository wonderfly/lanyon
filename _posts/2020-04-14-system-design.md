---
layout: post
title: System Design
category: [ design-patterns ]
toc: true
---

* TOC
{:toc}

# Design Netflix

![Netflix Architecture](/assets/netflix-arch.jpg)

From <https://medium.com/@narengowda/netflix-system-design-dbec30fede8d>.

## Notes

Video transcoding. For example, H.265 --> MP4. May change resolution and frame
rate to better user experience on a particular device.

Netflix also creates difference video files depending on the network speeds you
have. On average, 1200 files are created for one video.

Once a video is transcoded, the thousands of copies of it get pushed to the many
*streaming* servers that Netflix has, via its *C*ontent *D*ellivery *N*etwork
(CDN).

When a user clicks the play button on a video, a nearby streaming server is
matched, for the video copy with the best resolution and framerate for the
user's device.

Content recommendation. Netflix uses data mining (Hadoop) and machine learning
to recommend videos the user might enjoy watching based on their browse / view
history.

Client side. Netflix supports 2200 different devices: Android, iOS, gaming
consoles, web apps, etc, involving various client side technology. On the
website, they use React JS a lot, for its startup speed, runtime performance and
modularity.

Front end load balancing. User requests are routed to Netflix's frontends via
AWS's Elastic Load Balancer, which is the two tier load balancer. At the first
tier, it uses DNS based round robin to select an ELB endpoint in a particular
"zone". At the second tier, it does another round robin to select a server
within that zone.

EV Cache. A distributed key value store based on Memcached. Reads are served by
the nearest server, or a backup server if the nearest is down. Writes are
duplicated to all servers. SSDs are used for persistent yet performance storage.

Database. Static data like user profiles and billing information are stored in
MySql databases. Netflix runs its own MySql deployment on EC2 VMs. Handles
database replication and etc. Replicate fail-over is done via updating a DNS
entry for the DB host.

Cassandra. A distributed wide column NoSQL data store. Designed for consistent
read/write performance at scale. Netflix stores user viewing history in
Cassandra. Latest view history that undergos frequent reads and writes are
stored uncompressed while older history is compressed, to save storage.

Monitoring and event processing. The Netflix's clients generate a lot of events
every second of every day: ~500 billion events per day (~1.3 PB data) and ~8
million events and ~24GB data to be processed per second during peak hours.
Events include video viewing activities, UI activities, error logs, and etc.

They use Apache Chukwa to collect and monitor these events. Chukwa is based on
HDFS and Map Reduce. The collected events are routed by Kafka to various data
sinks: S3, Elastic Search, and possibly a secondary Kafka.

Netflix uses Elastic Search to help with mapping a user end failure (failure to
watch a video) to error logs. Elastic Search is a document search engine. AWS
has a managed version of it.

Autoscaling. When people get home from work, load increases and the system
automatically scales up.

Media processing. Switching gears a bit, over to the content production side.
Before a video is put on the Netflix site, it undergos a lot of processing
steps. For instance, large videos are split and encoded in chunks, in parallel.

Spark. Content recommendation and personalization is done via managed Spark
clusters.
