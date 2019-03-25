# Instantly grow crops in farm plots
=begin

growcrops
=========
Instantly grow seeds inside farming plots.

With no argument, this command list the various seed types
currently in use in your farming plots. With a seed type,
the script will grow specified seeds, ready to be harvested.

Arguments:

- ``list`` or ``help``
   List the various seed types currently in use in your farming plots

- ``<crop name>``
   Grow specific planted seed type

- ``all``
   Grow all planted seeds


Example:

- Grow plump helmet spawn:
   ``growcrops plump``

=end

# cache information from the raws
def cacheCropRaws()
    if @raws_crop_name.empty?
        # store ID and grow duration for each crop
        df.world.raws.plants.all.each_with_index { |p, idx|
            @raws_crop_name[idx] = p.id # Crop ID
            @raws_crop_growdur[idx] = p.growdur # Grow Duration
        }
    end
end

# create a list of available crops to grow, from seeds
def buildSeedList()
    df.world.items.other[:SEEDS].each { |seed|
        next if not seed.flags.in_building # skip if seed in building
        next if not seed.general_refs.find { |ref| ref._rtti_classname == :general_ref_building_holderst } # skip if seed in depot
        next if seed.grow_counter >= @raws_crop_growdur[seed.mat_index]
        # add to list of potential crops to grow
        @inventory[seed.mat_index] += 1
    }
end

# Display a list of planted crops
def listPlantedCrops()
    @inventory.sort_by { |mat, seedCount| seedCount }.each { |mat, seedCount|
        cropName = df.world.raws.plants.all[mat].id
        puts " #{cropName} #{seedCount}"
    }
end

# grow specific crop
def growCrop(material)
    # find the matching crop
    mat = df.match_rawname(material, @inventory.keys.map { |k| @raws_crop_name[k] })
    unless wantmat = @raws_crop_name.index(mat)
        raise "invalid plant material #{material}" # no crop with that name
    end
    # grow each seed for specified crop
    count = 0
    df.world.items.other[:SEEDS].each { |seed|
        next if seed.mat_index != wantmat # skip if not desired seed
        next if not seed.flags.in_building # skip if seed is in building
        next if not seed.general_refs.find { |ref| ref._rtti_classname == :general_ref_building_holderst } # skip if seed in depot
        next if seed.grow_counter >= @raws_crop_growdur[seed.mat_index] # skip if already grew desired amount
        seed.grow_counter = @raws_crop_growdur[seed.mat_index]
        count += 1
    }
    puts "Grown #{count} #{mat}"
end

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

material = $script_args[0]          # Grow which crop
@inventory = Hash.new(0)            # a list of available crops to grow, from seeds
@raws_crop_name ||= {}
@raws_crop_growdur ||= {}

# cache information from the raws
cacheCropRaws()

# create a list of available crops to grow, from seeds
buildSeedList()

if !material or material == 'help' or material == 'list'
    # show a list of available crop types
    listPlantedCrops()
else
    if material == 'all'
        # loop through all planted crops
        @inventory.sort_by { |mat, seedCount| seedCount }.each { |mat, seedCount|
            # grow that plant
            growCrop(df.world.raws.plants.all[mat].id)
        }
    else
        # grow a single crop type
        growCrop(material)
    end
end
