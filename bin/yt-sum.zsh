#!/bin/zsh

if [[ -z "$1" ]]; then
    echo "Usage: $(basename $0) <video_id>"
    return 1
fi

ytsum() {
	local model="gpt-oss:20b"
 	local tmp; tmp=$(mktemp)
 	yt-transcript "$1" > "$tmp"
 	local words; words=$(wc -w < "$tmp")
 	local toks=$(( words * 13 / 10 ))                # approx tokens (~1.3 tokens/word)
 	local want=$(( toks + 2048 ))                    # headroom for the summary
 	local ctx=$(( ((want + 4095) / 4096) * 4096 ))   # round up to next 4k
 	(( ctx < 4096  )) && ctx=4096                    # floor
 	(( ctx > 32768 )) && { ctx=32768; print -u2 "warn: transcript exceeds cap, truncating"; }
 	llm -m $model -o num_ctx "$ctx" \
 		--system 'Summarize this YouTube transcript. Start with a title. Use markdown headers but limit bold / italic. End with a structured object recommending action. {skip: confidence_level, read: confidence_level, watch: confidence_level, reason: reason} The three confidence_level values should range 0.0 - 1.0 and sum to 1.0.'  < "$tmp"
 	rm -f "$tmp"
	echo "model = ${model}; ctx = ${ctx}"
}

ytsum $1
