require 'mechanize'
require 'json'
require 'date'

date = Date.today

def film_parser(random_alhoritm, algorithms_hash, date, film_by_alhoritm)
  def transformator(*params)

    def get_new_element_to_hash(new_element, arry, name_hash)
      count = 0
      arry_size = arry.size

      new_element.each do |item_new_element|
        arry[count][name_hash] = item_new_element.text.to_s
        count += 1
        break if count >= arry_size
      end

      return arry
    end

    arry = []

    unless params[0].nil?
      i = 1

      loop do
        arry << {}
        i += 1
        break if i > params[0].size
      end

      count = 1

      params.each do |param|
        get_new_element_to_hash(param, arry, ("param" + count.to_s).to_sym)
        count += 1
      end
    else
      arry << 'ERROR: EMPTY PARAMS FOR GENERATE ARRAY'
    end
      
    return arry
  end

  page_uniq = true
  count = 0

  agent = Mechanize.new()

  while page_uniq do
    
    count += 1

    page = agent.get(algorithms_hash["#{random_alhoritm}"] + "&page=#{count}")
    film_snippet = page.search("//div[starts-with(@class, 'film-snippet film-snippet_in-catalogue film-snippet_type_movie')]")

    break if film_snippet.empty?

    if count == 1
      first_req = film_snippet.text[0..40]
      film_snippet_common = film_snippet
    else
      if film_snippet.text[0..40] != first_req
        film_snippet_common += film_snippet
        puts count
        break if count > 50
      else
        page_uniq = false
      end
    end
  end

  unless film_snippet_common.nil?

    title =         film_snippet_common.search("meta[itemprop='name'] @content")
    year_country =  film_snippet_common.search("div[@class='film-snippet__info']")
    link =          film_snippet_common.search("div[@class='film-snippet__media'] a @href")
    img =           film_snippet_common.search("img.image @src")

    abort "\nERROR: Big Dick\n\n" if film_snippet_common.empty?

    films = transformator(title, year_country, link, img) # здесь мы получаем большой массив с рассорированными параметрами

  else
    films = transformator()
  end

  hash_films = {date: date.strftime("%F"), data: films}

  f = File.new(film_by_alhoritm, 'w')
  f.puts(hash_films.to_json)
  f.close
end

def random_film(content)
  unless content['data'][0].is_a?String
    size = content['data'].size
    random = rand(size)

    film = content['data'][random]

    done_string = "Фильм: #{film['param1']}, #{film['param2']}"
  else
    done_string = content['data'][0]
  end
  return done_string
end

def get_json_content(film_by_alhoritm)
  f = File.new(film_by_alhoritm, 'r:UTF-8')
  content = f.read
  f.close
  content = JSON.parse(content)
end

file_path = File.dirname(__FILE__)
algorithms_file = file_path + "/algorithm.json"

begin
  algorithms_data = File.read (algorithms_file)
rescue Errno::ENOENT
  abort "ERROR DOWNLOAD ALGORITHMS"
end

algorithms_hash = JSON.parse(algorithms_data)
random_alhoritm = rand(algorithms_hash.size) + 1

film_by_alhoritm = file_path + "/films/#{random_alhoritm}.json"

if File.exist?(film_by_alhoritm)

  content = get_json_content(film_by_alhoritm)

  file_date = content['date']
  file_date = Date.strptime(file_date, '%F')
  subtr_date = (date - file_date).to_i

  if subtr_date < 7 + random_alhoritm
    puts random_film(content)
  else
    film_parser(random_alhoritm, algorithms_hash, date, film_by_alhoritm)
    puts random_film(get_json_content(film_by_alhoritm))
  end

else
  film_parser(random_alhoritm, algorithms_hash, date, film_by_alhoritm)
  puts random_film(get_json_content(film_by_alhoritm))
end