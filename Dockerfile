# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM alpine:latest
LABEL maintainer="Apache Nutch Committers <dev@nutch.apache.org>"
LABEL fork="Rekt <jose.tobias@outlook.com>"

WORKDIR /root/

# Install dependencies
RUN apk update
RUN apk --no-cache add bash wget ca-certificates

# ENV JAVA_HOME='/usr/lib/jvm/java-11-openjdk'
ENV NUTCH_HOME='/root/nutch/'
ENV REKT_HOME='/root/rekt'
ENV NUTCH_BINARY_ARCHIVE="apache-nutch-1.18-bin.tar.gz"
RUN echo 'export JAVA_HOME=${JAVA_HOME}' >> $HOME/.bashrc

# Download binary nutch and keys for check
RUN wget -q https://dlcdn.apache.org/nutch/1.18/apache-nutch-1.18-bin.tar.gz \
	&& wget -q https://apache.org/dist/nutch/1.18/apache-nutch-1.18-bin.tar.gz.sha512

RUN sha512sum apache-nutch-1.18-bin.tar.gz >local.sha512
RUN if [[ $(sed -E 's/^([a-z0-9]+)(.*)/\1/g' local.sha512) !=  $(sed -E 's/(.*)?\s([a-z0-9]*)?/\2/g' apache-nutch-1.18-bin.tar.gz.sha512) ]]; then echo "signature check failure"; exit 1; fi
RUN rm -rf apache-nutch-1.18-bin.tar.gz.sha512 && rm -rf local.sha512
RUN mkdir nutch && tar -xf apache-nutch-1.18-bin.tar.gz -C ${NUTCH_HOME} --strip-components=1 && rm -rf apache-nutch-1.18-bin.tar.gz

# Create symlinks for runtime/local/bin/nutch and runtime/local/bin/crawl
RUN ln -sf "${NUTCH_HOME}/bin/nutch" /usr/local/bin/
RUN ln -sf "${NUTCH_HOME}/bin/crawl" /usr/local/bin/
RUN ln -sf "${REKT_HOME}/rekt" /usr/local/bin/