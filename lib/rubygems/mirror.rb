require 'rubygems'
require 'fileutils'

class Gem::Mirror
  autoload :Fetcher, 'rubygems/mirror/fetcher'
  autoload :Pool, 'rubygems/mirror/pool'

  SPECS_FILE   = "specs.#{Gem.marshal_version}"
  SPECS_FILE_Z = "#{SPECS_FILE}.gz"

  LATEST_SPECS_FILE   = "latest_#{SPECS_FILE}"
  LATEST_SPECS_FILE_Z = "latest_#{SPECS_FILE_Z}"

  DEFAULT_URI = 'http://production.cf.rubygems.org/'
  DEFAULT_TO = File.join(Gem.user_home, '.gem', 'mirror')

  RUBY = 'ruby'

  def initialize(from = DEFAULT_URI, to = DEFAULT_TO, parallelism = 10)
    @from, @to = from, to
    @fetcher = Fetcher.new
    @pool = Pool.new(parallelism)
  end

  def from(*args)
    File.join(@from, *args)
  end

  def to(*args)
    File.join(@to, *args)
  end

  def update_specs
    # update specs and latest_specs files
    specz = to(SPECS_FILE_Z)
    @fetcher.fetch(from(SPECS_FILE_Z), specz)
    open(to(SPECS_FILE), 'wb') { |f| f << Gem.gunzip(File.read(specz)) }

    latest_specz = to(LATEST_SPECS_FILE_Z)
    @fetcher.fetch(from(LATEST_SPECS_FILE_Z), latest_specz)
    open(to(LATEST_SPECS_FILE), 'wb') { |f| f << Gem.gunzip(File.read(latest_specz)) }
  end

  def gems
    update_specs unless File.exists?(to(SPECS_FILE))

    gems = Marshal.load(File.read(to(SPECS_FILE)))
    gems.map! do |name, ver, plat|
      # If the platform is ruby, it is not in the gem name
      "#{name}-#{ver}#{"-#{plat}" unless plat == RUBY}.gem"
    end
    gems
  end

  def existing_gems
    Dir[to('gems', '*.gem')].entries.map { |f| File.basename(f) }
  end

  def gems_to_fetch
    gems - existing_gems
  end

  def gems_to_delete
    existing_gems - gems
  end

  def update_gems
    gems_to_fetch.each do |g|
      @pool.job do
        @fetcher.fetch(from('gems', g), to('gems', g))
        yield
      end
    end

    @pool.run_til_done
  end

  def delete_gems
    gems_to_delete.each do |g|
      @pool.job do
        File.delete(to('gems', g))
        yield
      end
    end

    @pool.run_til_done
  end

  def update
    update_specs
    update_gems
    cleanup_gems
  end
end
