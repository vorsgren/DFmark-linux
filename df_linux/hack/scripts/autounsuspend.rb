# un-suspend construction jobs, on a recurring basis
=begin

autounsuspend
=============
Automatically unsuspend construction jobs, on a recurring basis.

Will not unsuspend jobs where water flow > 1.

See `unsuspend` for one-off use, or `resume` ``all``.

=end

class AutoUnsuspend
    attr_accessor :running

    def process
        count = 0
        df.world.jobs.list.each { |job|
            if job.job_type == :ConstructBuilding and job.flags.suspend and df.map_tile_at(job).designation.flow_size <= 1
                # skip planned buildings
                next if job.job_items.length == 1 and job.job_items[0].item_type == :NONE
                job.flags.suspend = false
                count += 1
            end
        }
        if count > 0
            puts "Unsuspended #{count} job(s)."
            df.process_jobs = true
        end
    end

    def start
        @running = true
        @onupdate = df.onupdate_register('autounsuspend', 100) { process if @running }
    end

    def stop
        @running = false
        df.onupdate_unregister(@onupdate)
    end
end

case $script_args[0]
when 'start'
    $AutoUnsuspend ||= AutoUnsuspend.new
    $AutoUnsuspend.start

when 'end', 'stop'
    $AutoUnsuspend.stop

else
    puts $AutoUnsuspend && $AutoUnsuspend.running ? 'Running.' : 'Stopped.'
end
