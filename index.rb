require 'json'
require 'csv'

INPUT_FILE = 'sample.json'
OUTPUT_FILE = 'output.csv'

class BoundaryPoint
  attr_accessor :input_file
  attr_accessor :room_index
  attr_accessor :json

  def initialize(input_file)
    @json = nil
    @room_index = 1
    @input_file = input_file

    remove_output
    load_json
  end

  def load_json
    file = File.open @input_file
    @json = JSON.load file.read
  end

  def remove_output
    begin
      File.unlink OUTPUT_FILE
    rescue
    end
  end

  def generate
    search_and_generae_csv @json
  end

  def search_and_generae_csv(obj)
    case obj
    when Array
      obj.each do |array|
        search_and_generae_csv array
      end
    when Hash
      obj.each do |key, value|
        if key == 'rooms'
          value.each do |room|
            append_csv room
          end
        else
          search_and_generae_csv value
        end
      end
    end
  end

  def append_csv(room)
    CSV.open OUTPUT_FILE, 'a' do |csv|
      boundary_points = room['properties']['boundaryPoints']

      if boundary_points.length.zero?
          csv << [
            room['properties']['name'],
            @room_index
          ]
      else
        boundary_points.each do |boundary_point|
          csv << [
            room['properties']['name'],
            @room_index,
            boundary_point['X'],
            boundary_point['Y'],
            boundary_point['Z']
          ]

        end
      end
    end

    @room_index += 1
  end
end

boundary_point = BoundaryPoint.new INPUT_FILE
boundary_point.generate
