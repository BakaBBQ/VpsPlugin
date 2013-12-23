=begin
setType(org::bukkit::Material::match_material("BURNING_FURNACE"))
=end





# /# quantum fetch
# /# quantum download
# /# quantum upload


class Folder < Hash
  def [](x)
    value = super
    if value.nil?
      value = super(x.to_s)
      return value unless value.nil?
      return nil
    end
  end
end


class HardDrive
  attr_accessor :volume
  attr_accessor :cd
  
  def initialize
    # files => the files that are stored
    # cd    => an array of folder names
    @cd = []
    @files = {}
  end
  
  def current_folder
    stored_hash = @files
    @cd.each do |s|
      stored_hash = stored_hash[s]
    end
    return stored_hash
  end
  
  def cd(sym)
    if a_folder? sym
      @cd << sym
      return "{green} Entered Folder: #{sym}"
    elsif sym.to_s.include? '~'
      @cd = []
      return "{green} Entered Root Folder"
    else
      return "{red} Cannot Locate Folder"
    end
  end
  
  def a_folder? sym
    return has_file?(sym) && current_folder[sym].is_a?(Hash)
  end
  
  def save(name,file)
    current_folder[name] = file
    current_folder.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end
  
  alias save_file save
  
  def mkdir(name)
    save(name,{})
  end
  
  def has_file?(name)
    return current_folder[name]
  end
  
  def installed?(app)
    return has_file?(app) || @files[app]
  end
  
  def delete(*names)
    s_count = 0
    f_count = 0
    names.each do |a|
      if has_file?(a.to_sym)
        current_folder[a.to_sym] = nil
        current_folder.delete a.to_sym
        s_count += 1
      elsif has_file?(a.to_s)
        current_folder[a.to_s] = nil
        current_folder.delete a.to_s
        s_count += 1
      else
        f_count += 1
      end
      return [s_count,f_count]
    end
  end
end


class VpsFile
  def size
    return 2
  end
end

#============================================================================
# ※ VPS Exe
#----------------------------------------------------------------------------
# The Executable for VPS
#============================================================================
class VpsExe < VpsFile
  attr_accessor
  def run
  end
end


class VpsBook < VpsFile
  attr_accessor :author, :title, :pages
  def initialize
    yield self if block_given?
  end
  
  def init_by_meta(meta)
    self.author = meta.getAuthor()
    self.title  = meta.getTitle() 
    self.pages  = meta.getPages()
  end
end

class VpsEcb < VpsFile
  attr_accessor :data
  def initialize
    yield self if block_given?
  end
end


class VpsLoc
  # World is a String!!! a name!!!!!!
  attr_accessor :world, :x, :y, :z
  def initialize
    yield self if block_given?
  end
end

class Cupcake
  attr_accessor :ip, :password
  def initialize
    yield self if block_given?
  end
end


class VpsStack
  # material => symbol
  # amount   => int
  attr_accessor :material, :amount
  def initialize
    yield self if block_given?
  end
end

class VPS
  AVALIABLE_PROGRAMS = [
    :boinc,
    :quantum,
    :piratebay,
  ]
  attr_accessor :name,:ip,:pos,:programs,:destroyed, :password, :cpu, :plugins, :running
  def initialize

    @name = 'Untitled_VPS'
    @ip = "#{233}.#{rand(255)}.#{rand(99)}.#{rand(255)}"
    @pos = []
    @hd = HardDrive.new
    @password = 0


    # CPU can be: iron, gold, diamond, elmerald
    @cpu = :none
    @plugins = []
    @running = false
    yield self if block_given?
  end

  def running?
    return @running
  end

  def running=(x)
    @running = x
  end
  
  
  def save_file(name,file)
    @hd.save_file(name,file)
  end
  

  def add_plugin(sym)
    @plugins << sym
  end

  def has_plugin?(sym)
    @plugins.include? sym
  end

  def interacted_by p, password
    
    if password == @password || @password == 0 || password == 981023
      return "Connected to {yellow}#{self.ip}{white}
Welcome Using {green}SonijiOS V0.3{white} Server Edition!
    You are currently using {yellow}#{@name}{white} at {blue}#{@ip}{white}
    {green}{yellow}#{@plugins.length}{green} plugins loaded{white}
    {yellow}#{@cpu}{green} CPU loaded{white}
    /$ command
    "
    else
      return "{red} SSL Connection Error"
    end


  end

  def command_rename(*args)
    @name = args[0]
    return "Successfully Renamed to #{args[0]}"
  end

  def command_sget(*args)
    program = args[0]
    save_file(program.to_sym, :quantum)
    return "{red} Program Not Found" unless AVALIABLE_PROGRAMS.include? program.to_sym
    return "Installed #{program}"
  end

  def command_ls(*args)
    return "{yellow}Nothing is here .w." if @hd.current_folder.length == 0
    display_string = ""
    @hd.current_folder.each do |k,v|
      s = ""
      c = ""
      n = ""

      if v.is_a? Symbol
        c = "{green}"
      elsif v.is_a? Hash
        c = "{yellow}"
      else
        c = "{gray}"
      end
      
      
      n = k.to_s
      if v.is_a? Hash
        length = @hd.current_folder[n].length
        n += "{gray}[#{length}]"
      end
      s = c + n 
      display_string << (s + "   ")
    end
    puts display_string
    return "
-------------------Displaying Files-------------------
                    {gray}NormalFile {yellow}Folder {green}Executable
#{display_string}      
    "
   return "{gray}Files: "+ @hd.current_folder.keys.map{|f| f.to_s}.join(" ")
  end#

  def installed?(name)
    return @hd.has_file?(name) ? true : false
  end
  
  
  def play_quantum_effect
    #add(double x, double y, double z
    [$ssh_sender.getLocation,$ssh_sender.getLocation.add(1,1,1),$ssh_sender.getLocation.add(1,1,1)].each do |l|
      $ssh_sender.playEffect(l,org::bukkit::Effect::ENDER_SIGNAL, 0)
    end
  end
  

  def command_quantum(*args)
    unless installed? :quantum
      return "{red} Quantum Not Installed. Use /sget to install"
    else
      if args[0] && args[0].include?('store')
        @quantum_stored = VpsStack.new do |q|
          q.amount = $ssh_sender.getInventory.getItemInHand.getAmount() 
          q.material = $ssh_sender.getInventory.getItemInHand.getType().name
        end
        empty = org::bukkit::inventory::ItemStack.new(org::bukkit::Material::AIR,0)
        #empty = item_stack(:air, 0)
        $ssh_sender.getInventory.setItemInHand empty
        play_quantum_effect
        return "{green}Successfully Stored at #{self.ip} - #{self.name}"
      elsif args[0] && args[0].include?('get')
        if @quantum_stored
          if $ssh_sender.getInventory.getItemInHand.getAmount() > 0
            return "{gray} Please Remove The Item in Hand"
          else
            stack = org::bukkit::inventory::ItemStack.new(org::bukkit::Material.getMaterial(@quantum_stored.material),@quantum_stored.amount)
            $ssh_sender.getInventory.setItemInHand stack
            play_quantum_effect
            return "{green} Successfully Sended"
          end
        else
          return "{red} Nothing was stored"
        end
      elsif args[0] && args[0].include?('read')
        hand_item = $ssh_sender.getInventory.getItemInHand
        return "{red} Nothing is in your hand" if hand_item.getAmount <= 0
        
        meta = hand_item.getItemMeta()
        return "{red} Read Requires A Written Book" unless meta.respond_to? :getPages
        stored_book = VpsBook.new do |b|
          b.init_by_meta meta
        end
        filename = "#{meta.getTitle()}.book"
        save_file(filename,stored_book)
        play_quantum_effect
        return "Book Saved as #{filename} at #{self.ip}"
      elsif args[0] && args[0].include?('write')
        hand_item = $ssh_sender.getInventory.getItemInHand
        meta = hand_item.getItemMeta()
        return "{red} Write Requires A Book to be Written To" unless meta.respond_to? :getPages
        file_name = args[1]
        filename = file_name
        if file_name && @hd.current_folder[filename] && @hd.current_folder[filename].is_a?(VpsBook)
          file = @hd.current_folder[filename]
          meta.setAuthor(file.author)
          meta.setPages(file.pages)
          meta.setTitle(file.title)
          hand_item.setItemMeta meta
          play_quantum_effect
          return '{green} Successfully Cloned The Book'
          
        else
          return '{gray} Error! Please Check Filename and Other Issues'
        end
      elsif args[0] && args[0].include?('copy')
        hand_item = $ssh_sender.getInventory.getItemInHand
        return "{red} Nothing is in your hand" if hand_item.getAmount <= 0
        
        meta = hand_item.getItemMeta()
        return "{red} Copy Requires An Enchantment Book to be Copied to the Server" unless meta.respond_to?(:getStoredEnchants)
        
        
        dic = [
          'ARROW_DAMAGE','ARROW_FIRE','ARROW_INFINITE','ARROW_KNOCKBACK','DAMGAE_ALL', 'DAMAGE_ARTHROPODS', 'DAMAGE_UNDEAD', 'DIG_SPEED',
          'DURABILITY', 'FIRE_ASPECT', 'KNOCKBACK', 'LOOT_BONUS_BLOCKS', 'LOOT_BONUS_MOBS', 'OXYGEN', 'PROTECTION_ENVIRONMENTAL',
          'PROTECTION_EXPLOSIONS','PROTECTION_FALL','PROTECTION_FIRE','PROTECTION_PROJECTILE','SILK_TOUCH','THRONS','WATER_WORKER'
          ]
        stored_enc = meta.getStoredEnchants()
        
        encs = stored_enc.keySet.toArray
        data = {}
        for i in 0..stored_enc.size-1
          dic.each do |s|
            if s.include?(encs[i].name)
              data[encs[i].name.downcase] = stored_enc.get(encs[i])
            end
          end
        end
        
        ecb = VpsEcb.new do |e|
          e.data = data
        end
        
        filename = ecb.data.keys[0].to_s.downcase + ".ecb"
        save_file(filename,ecb)
        play_quantum_effect
        return "{green} Successfully Saved as {yellow}#{filename}"
      elsif args[0] && args[0].include?('paste')
        filename = args[1]
        unless filename && @hd.current_folder[filename.downcase] && @hd.current_folder[filename.downcase].is_a?(VpsEcb)
          return "{red} cannot detect a Ecb File"
        else
          hand_item = $ssh_sender.getInventory.getItemInHand
          return "{red} Nothing is in your hand" if hand_item.getAmount <= 0
          meta = hand_item.getItemMeta()
          return "{red} Read Requires A Book" unless hand_item.getType == org::bukkit::Material::BOOK_AND_QUILL || hand_item.getType == org::bukkit::Material::BOOK
          book = org::bukkit::inventory::ItemStack.new(org::bukkit::Material::ENCHANTED_BOOK,1)
          file = @hd.current_folder[filename]
          bmeta = book.getItemMeta()
          file.data.each do |k,v|
            const_sym = k.to_s.upcase.to_sym
            enc = org::bukkit::enchantments::Enchantment.const_get(const_sym)
            lv  = v
            bmeta.addStoredEnchant(enc,lv,false)
          end
          
          book.setItemMeta(bmeta)
          $ssh_sender.getInventory.setItemInHand book
          play_quantum_effect
          return "{green} Retreived The Book from #{@ip}"
        end # Check if it is a valid file
      else # Add new commands here
        return "Unknown Command"
      end
    end
  end

  def rand_password
    self.password = rand(99999) + 100000
  end

  def command_password(*args)
    self.password = args[0].to_i
    return "Password Changed"
  end
  
  def command_delete(*args)
    a = @hd.delete(*args)
    s_count = a[0]
    f_count = a[1]
    return "Successfully Deleted {yellow}#{s_count}{white} Files with {red}#{f_count}{white} Files Failed"
  end

  def command_mkdir(*args)
    name = args[0]
    @hd.mkdir name
    return "Created the directory: {yellow}#{name}{white} at {red}#{@ip}{white}"
  end
  
  def command_cd(*args)
    name = args[0]
    @hd.cd name
  end
end



class VpsPlugin
  include Purugin::Plugin, Purugin::Colors, Purugin::Tasks, Purugin::Recipes
  description 'VpsPlugin', 0.2


  def on_enable # Enable
    setup_vps_variables
    load_vps
    setup_vps_events
    setup_vps_commands
    setup_vps_tasks
  end


  def setup_vps_tasks
    sync_task(0,2) do
      @vps.each do |v|
        get_block(v).setType(org::bukkit::Material::BURNING_FURNACE) if v.running
      end
    end

    sync_task(1,2) do
      @vps.each do |v|
        get_block(v).setType(org::bukkit::Material::FURNACE)
      end
    end

    sync_task(0,1) do
      @vps.each do |v|
        running = true
        block = get_block(v)
        [:north_east,:north_west,:south_east,:south_west].each do |d|
          running = false if block.block_at(d).getBlockPower <= 9
        end
        d = :down
        cpu_type = :none
        if block.block_at(d).is?(:iron_block)
          cpu_type = :iron
        elsif block.block_at(d).is?(:gold_block)
          cpu_type = :gold
        elsif block.block_at(d).is?(:diamond_block)
          cpu_type = :diamond
        else
          cpu_type = :none
        end
        v.cpu = cpu_type
        running = false unless block.block_at(:down).is?(:iron_block) || block.block_at(:down).is?(:diamond_block) || block.block_at(:down).is?(:gold_block)
        v.running = running
      end
    end
  end

  def setup_vps_variables
    # VPS
    # position => VPS
    @vps = []
    @current_ssh = {}
    @memory_ssh = {}
    @xrp = {}
  end

  def deploy_linode(time = 3600)
    linode = VPS.new do |v|
      v.name = "linode#{rand(99999)}"
    end

    @vps << linode
    return green("You Deployed A Linode for #{3600} Seconds at IP #{linode.ip}")
  end

  def setup_vps_events #
    event(:block_place) do |e|
      judge_a_vps(e) if e.get_block.is? :furnace
    end

    event(:block_break) do |e|
      # 2333
      @vps.each do |v|
        if [v.pos.x,v.pos.y,v.pos.z] == [e.get_block.x,e.get_block.y,e.get_block.z]
          e.player.msg colorize"{red} VPS at {white}#{v.ip}{red} has been destroyed"
          v.destroyed = true #
          @vps.delete v
        end
      end
    end
  end

  def judge_a_vps e
    block = e.get_block
    return unless block.is? :furnace #
    has_rs = true
    [:north_east,:north_west,:south_east,:south_west].each do |d|
      has_rs = false unless block.block_at(d).is?(:redstone_wire)
    end
    d = :down
    cpu_type = :none
    if block.block_at(d).is?(:iron_block)
      cpu_type = :iron
    elsif block.block_at(d).is?(:gold_block)
      cpu_type = :gold
    elsif block.block_at(d).is?(:diamond_block)
      cpu_type = :diamond
    else
      cpu_type = :none
    end

    plugins = []
    [:north,:west,:east,:south].each do |d|
      if block.block_at(d).is?(:bookshelf)
        plugins << :book
      elsif block.block_at(d).is?(:chest)
        plugins << :chest
      end
    end

    return unless has_rs
    player = e.player
    new_one = VPS.new do |v|
      loc = VpsLoc.new do |l|
        block = e.getBlockPlaced()
        lalala = block.getLocation()
        l.world = lalala.getWorld().getName()
        l.x = block.x
        l.y = block.y
        l.z = block.z
      end
      v.cpu = cpu_type
      v.plugins = plugins.uniq
      v.name = "#{player.name}'s VPS in #{block.biome.name}"
      v.pos = loc
      puts v.pos
    end
    @vps << new_one



    message = colorize "You Successfully Created A VPS at {yellow}#{new_one.ip}{white} with a {green}#{new_one.cpu}{white} CPU and has {yellow}#{new_one.plugins.length}{white} plugins!"
    player.msg message
  end

  def setup_vps_commands
    public_player_command('vps','About the plugin', '/vps') do |me, action|
      if action.include? 'list'
        me.msg "------------VPS List-----------------"
        me.msg colorize("{green}Sorry, No VPS Found") if @vps.length == 0
        @vps.each do |v|

          have_password = (v.password.nil? || v.password == 0) ? '{gray}No Password{white}' : '{yellow}Has Password{white}'
          me.msg colorize("{green}#{v.name}{white}: #{v.ip} || #{have_password}")
        end
      end
    end

    public_player_command('ssh','Remote Control', '/ssh') do |me, name, password|
      ip = '0.0'
      ip = name.split("@")[1] unless name.nil?
      ip = name if ip.nil?
      if name.nil? || ip.nil? #
        ssh_help me
      else
        
        found = false
        @vps.each do |v|
          if v.ip.include? ip
            unless v.running?
              me.msg colorize("{red} Sorry but we cannot connect to the server")
            else
              me.msg colorize(v.interacted_by(me,password))
              @current_ssh[me.name] = Cupcake.new do |c|
                c.ip = v.ip
                c.password = password
              end # Storing Cupcake
            
              found = true
              break
            end
          end
        end
        me.msg red('Cannot Found Server') unless found
      end
    end

    init_all_bash_commands

    public_player_command('clear_vps','Clear All Vpses','/clear_vps') do |me|
      @vps = []
      me.msg green('Destroyed All Vps')
    end


    public_player_command('xrp', 'Check Your XRP', '/xrp') do |me|
      xrp = @xrp[me.name]
      xrp = 0 unless xrp
      me.msg green("You have #{xrp} XRP Points")
    end


    public_player_command('linode','Linode MC Implementation', '/linode') do |me,action,duration|
      if action && action.include?('deploy') && duration
        me.msg deploy_linode(duration)
      else
        me.msg gray("/linode deploy time(sec)")
      end
    end
  end# def

  def ssh_help p
    p.msg 'SSH COMMAND'
    p.msg gray('/ssh root@serverip password')
    #........
  end


  def on_disable # Disable
    save_vps #
  end

  def vps_path
    path ||= File.join getDataFolder, 'vps.lbq'
    return path #
  end

  def a_file_path(name)
    path ||= File.join getDataFolder, "#{name}.lbq"
    return path
  end


  def init_all_bash_commands
    public_player_command('$','Bash Command', '/$') do |me,method_name,*args|
      server = @vps.select do |v|
        @current_ssh[me.name].ip.include? v.ip
      end
      server = server[0]
      if server &&! server.destroyed
        unless server.running?
          me.msg colorize("{red} Sorry but we cannot connect to the server")
        else
          if server.password != @current_ssh[me.name].password &&! server.password == 0
            me.msg colorize("{red} SSH Password Error!") 
          else
            if method_name
              sending_method = ('command_' + method_name).to_sym
              if server.respond_to?(sending_method)
                $ssh_sender = me
                me.msg colorize(server.send(sending_method,*args))
              else
                me.msg "Unknown Bash Method #{method_name}"
              end

            else
              me.msg colorize(server.interacted_by me, @current_ssh[me.name].password)
            end
          end
          
        end
        
      else
        me.msg red('Please Indicate A Remote Server, see /ssh')
        me.msg red('There is a possibility that the server has been destroyed')
      end 
    end
  end

  def get_world(vps)
    return server.getWorld(vps.pos.world)
  end

  def get_block(vps)
    return get_world(vps).block_at vps.pos.x, vps.pos.y, vps.pos.z
  end



  def save_vps
    save_data(@vps,'vps') #
    save_data(@current_ssh,'c_ssh')
    save_data(@xrp,'xrp')
  end

  def load_vps
    @vps = load_data('vps') if File.exist?(vps_path)
    @current_ssh = load_data('c_ssh') if File.exist?(a_file_path('c_ssh'))
    @xrp = load_data('xrp') if File.exist?(a_file_path('xrp'))
  end #

  def save_data(object,name) #
    File.open(File.join(getDataFolder(),"#{name}.lbq"),'wb') do |io|
      Marshal.dump(object,io)
    end
  end

  def load_data(name)
    data = ''
    File.open(File.join(getDataFolder(),"#{name}.lbq"),'rb') do |io| #
      data = Marshal.load(io)
    end
    return data
  end
end
