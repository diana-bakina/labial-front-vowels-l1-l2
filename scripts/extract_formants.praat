# Name of the Textgrid file that is annotated
name$ = "participant_1_fr"

# How many timepoints?
num_timepoints = 10

# Which tier are your annotations?
v_tier = 2
word_tier = 1
trial_tier = 3

# Make the table
Create Table with column names: "formants", 0, "vowel word trial time_index v_time time_abs F1 F2 F3"
row_index = 0

# Count the intervals
select TextGrid 'name$'
num_intervals = Get number of intervals: v_tier

# Loop through the intervals
for interval_index from 1 to num_intervals
    select TextGrid 'name$'
    label$ = Get label of interval: v_tier, interval_index

    # proceed if the label isn't empty
    if label$ <> ""
        t_start = Get start time of interval: v_tier, interval_index
        t_end = Get end time of interval: v_tier, interval_index
        time_interval = (t_end - t_start) / (num_timepoints - 1)

        # Get word label from overlapping word tier
        word$ = ""
        num_word_intervals = Get number of intervals: word_tier
        found_word = 0
        for w from 1 to num_word_intervals
            if found_word = 0
                word_start = Get start time of interval: word_tier, w
                word_end = Get end time of interval: word_tier, w
                if word_start <= t_start and word_end >= t_end
                    word$ = Get label of interval: word_tier, w
                    found_word = 1
                endif
            endif
        endfor

        # Get trial number from overlapping trial tier
        trial$ = ""
        num_trial_intervals = Get number of intervals: trial_tier
        found_trial = 0
        for a from 1 to num_trial_intervals
            if found_trial = 0
                trial_start = Get start time of interval: trial_tier, a
                trial_end = Get end time of interval: trial_tier, a
                if trial_start <= t_start and trial_end >= t_end
                    trial$ = Get label of interval: trial_tier, a
                    found_trial = 1
                endif
            endif
        endfor

        selectObject: "Formant 'name$'"

        # Loop through the timepoints
        for time_index from 1 to num_timepoints
            time_re_onset = (time_index - 1) * time_interval
            current_time = t_start + time_re_onset

            select Formant 'name$'
            f1 = Get value at time: 1, current_time, "hertz", "Linear"
            f2 = Get value at time: 2, current_time, "hertz", "Linear"
            f3 = Get value at time: 3, current_time, "hertz", "Linear"

            # Add info to the table
            select Table formants
            Insert row: row_index + 1
            row_index = row_index + 1
            Set string value: row_index, "vowel", label$
            Set string value: row_index, "word", word$
            Set string value: row_index, "trial", trial$
            Set numeric value: row_index, "time_index", time_index
            Set numeric value: row_index, "v_time", time_re_onset
            Set numeric value: row_index, "time_abs", current_time

            if f1 <> undefined
                Set numeric value: row_index, "F1", f1
            else
                Set string value: row_index, "F1", "NA"
            endif
            if f2 <> undefined
                Set numeric value: row_index, "F2", f2
            else
                Set string value: row_index, "F2", "NA"
            endif
            if f3 <> undefined
                Set numeric value: row_index, "F3", f3
            else
                Set string value: row_index, "F3", "NA"
            endif
        endfor
    endif
endfor
