(defproject amperity/solanum "1.0.0-SNAPSHOT"
  :description "Local host monitoring daemon."
  :url "https://github.com/amperity/solanum"
  :license {:name "Public Domain"
            :url "http://unlicense.org/"}

  :aliases
  {"coverage" ["with-profile" "+coverage" "cloverage"]}

  :deploy-branches ["master"]
  :pedantic? :abort

  :dependencies
  [[org.clojure/clojure "1.12.2"]
   [org.clojure/data.json "2.5.1"]
   [org.clojure/tools.cli "1.3.250"]
   [org.clojure/tools.logging "1.3.1"]
   [ch.qos.logback/logback-classic "1.5.23"]
   [http-kit "2.8.1"]
   [org.yaml/snakeyaml "2.5"]
   [riemann-clojure-client "0.5.4"]]

  :hiera
  {:cluster-depth 2
   :vertical false
   :show-external false
   :ignore-ns #{solanum.config}}

  :profiles
  {:repl
   {:pedantic? false
    :source-paths ["dev"]
    :jvm-opts ["-DSOLANUM_LOG_APPENDER=repl"]
    :dependencies
    [[org.clojure/tools.namespace "1.5.0"]]}

   :test
   {:jvm-opts ["-DSOLANUM_LOG_APPENDER=nop"]}

   :coverage
   {:jvm-opts ["-DSOLANUM_LOG_APPENDER=nop"]
    :plugins
    [[org.clojure/clojure "1.12.2"]
     [lein-cloverage "1.2.2"]]}

   :provided
   {:dependencies [[org.graalvm.nativeimage/svm "25.0.1"]]}

   :svm
   {:java-source-paths ["svm/java"]
    :dependencies [[com.github.clj-easy/graal-build-time "1.0.5"]]}

   :uberjar
   {:target-path "target/uberjar"
    :uberjar-name "solanum.jar"
    :main solanum.main
    :aot :all}})
