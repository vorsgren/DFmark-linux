# give super-dwarven speed to an unit
=begin

superdwarf
==========
Similar to `fastdwarf`, per-creature.

To make any creature superfast, target it ingame using 'v' and::

    superdwarf add

Other options available: ``del``, ``clear``, ``list``.

This script also shortens the 'sleeping' periods of targets.

=end

$superdwarf_onupdate ||= nil
$superdwarf_ids ||= []

case $script_args[0]
when 'add'
    if u = df.unit_find
        $superdwarf_ids |= [u.id]

        $superdwarf_onupdate ||= df.onupdate_register('superdwarf', 1) {
            if $superdwarf_ids.empty?
                df.onupdate_unregister($superdwarf_onupdate)
                $superdwarf_onupdate = nil
            else
                $superdwarf_ids.each { |id|
                    if u = df.unit_find(id) and not u.flags1.inactive
                        u.actions.each { |a|
                            case a.type
                            when :Move
                                a.data.move.timer = 1
                            when :Climb
                                a.data.climb.timer = 1
                            when :Job
                                a.data.job.timer = 1
                            when :Job2
                                a.data.job2.timer = 1
                            when :Attack
                                # Attack execution timer; fires when reaches zero.
                                a.data.attack.timer1 = 1
                                # Attack completion timer: finishes action at zero.
                                # An action must complete before target re-seleciton
                                # occurs.
                                a.data.attack.timer2 = 0
                            end
                        }

                        # no sleep
                        if u.counters2.sleepiness_timer > 10000
                            u.counters2.sleepiness_timer = 1
                        end

                    else
                        $superdwarf_ids.delete id
                    end
                }
            end
        }
    else
        puts "Select a creature using 'v'"
    end

when 'del'
    if u = df.unit_find
        $superdwarf_ids.delete u.id
    else
        puts "Select a creature using 'v'"
    end

when 'clear'
    $superdwarf_ids.clear

when 'list'
    puts "current superdwarves:", $superdwarf_ids.map { |id| df.unit_find(id).name }

else
    puts "Usage:",
        " - superdwarf add: give superspeed to currently selected creature",
        " - superdwarf del: remove superspeed to current creature",
        " - superdwarf clear: remove all superpowers",
        " - superdwarf list: list super-dwarves"
end
