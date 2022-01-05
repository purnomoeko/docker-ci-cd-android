FROM ubuntu:21.04
LABEL MAINTAINER Eko<eko.purnomo@icloud.com>

ENV VERSION_TOOLS "6858069"

ENV ANDROID_SDK_ROOT "/sdk"
# Keep alias for compatibility
ENV ANDROID_HOME "${ANDROID_SDK_ROOT}"
ENV PATH "$PATH:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive



RUN apt-get update \
    && apt-get install -qqy --no-install-recommends \
    bzip2 \
    curl \
    git-core \
    html2text \
    openjdk-11-jdk \
    libc6 \
    libstdc++6 \
    libgcc1 \
    libncurses6 \
    libz1 \
    unzip \
    locales \
    wget \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/commandlinetools-linux-${VERSION_TOOLS}_latest.zip > /cmdline-tools.zip \
    && mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && unzip /cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest \
    && rm -v /cmdline-tools.zip

RUN mkdir -p $ANDROID_SDK_ROOT/licenses/ \
    && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e\n24333f8a63b6825ea9c5514f83c2829b004d1fee" > $ANDROID_SDK_ROOT/licenses/android-sdk-license \
    && echo "84831b9409646a918e30573bab4c9c91346d8abd\n504667f4c0de7af1a06de9f4b1727b84351f2910" > $ANDROID_SDK_ROOT/licenses/android-sdk-preview-license \
    && yes | sdkmanager --licenses >/dev/null

RUN mkdir -p /root/.android \
    && touch /root/.android/repositories.cfg \
    && sdkmanager --update

ADD packages.txt /sdk
RUN sdkmanager --package_file=/sdk/packages.txt

# Install gradle
# RUN apt-get update
RUN apt-get install wget
RUN wget https://downloads.gradle-dn.com/distributions/gradle-6.9.2-all.zip
RUN unzip gradle-6.9.2-all.zip -d /opt

ENV GRADLE_HOME /opt/gradle-6.9.2-all/
ENV PATH $PATH:/opt/gradle-6.9.2-all/bin

#GEM 
RUN apt-get update
RUN apt-get install --no-install-recommends -y --allow-unauthenticated build-essential git ruby-full && \
    gem install rake && \
    gem install fastlane && \
    gem install bundler && \
    # Clean up
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean