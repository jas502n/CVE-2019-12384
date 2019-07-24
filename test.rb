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
