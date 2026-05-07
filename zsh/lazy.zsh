#eval $(dircolors -b ~/.dirc)
#xinput set-prop 10 "Device Enabled" 0
# Profiling option
#  zmodload zsh/zprof && zprof

autoload -Uz bashcompinit && bashcompinit
(( $+commands[aws_completer] )) && complete -C aws_completer aws

if (( $+commands[kubetui] )); then
  _kubetui_cache="$HOME/.zsh/cache/kubetui.zsh"
  if [[ ! -r "$_kubetui_cache" ]]; then
    kubetui completion zsh > "$_kubetui_cache"
  fi
  source "$_kubetui_cache"
  unset _kubetui_cache
fi

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh

function grvim(){
  local _grep_cmd
  if [[ "$(uname -s)" == "Darwin" ]]; then
    _grep_cmd=ggrep
  else
    _grep_cmd=grep
  fi

  # Init vars
  file=""
  line=""

  ARGS=()
  IGNORE_PATTERN=()
  IGNORE_PATTERN+=(-e ".git" -e "venv" -e ".tox")
  while (( $# > 0 ))
  do
    case $1 in
      -v)
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "'option' requires an argument." 1>&2
          exit 1
        else
          IGNORE_PATTERN+=(-e "$2")
          shift
        fi
        ;;
      *)
        ARGS=("${ARGS[@]}" "$1")
        ;;
    esac
    shift
  done

  if [[ "${#ARGS[@]}" -lt 1 ]]; then
    echo "Too few arguments." 1>&2
  elif [[ "${#ARGS[@]}" -gt 1 ]]; then
    echo "Too many arguments." 1>&2
  fi

  get_nth () {
    local n=$1
    shift
    eval echo \$${n}
  }

  REGEX_PATTERN=$(get_nth 1 "${ARGS[@]}")

  if [ ${#IGNORE_PATTERN[@]} -eq 0 ]; then
    res="`$_grep_cmd --color=auto -rI -n "$REGEX_PATTERN" |peco`"
  else
    res="`$_grep_cmd --color=auto -rI -n "$REGEX_PATTERN" |$_grep_cmd -v ${IGNORE_PATTERN[@]} |peco`"
  fi
  file="$(awk -F: -v t="$res" 'BEGIN{split(t, a); print a[1]}')"
  line="$(awk -F: -v t="$res" 'BEGIN{split(t, a); print a[2]}')"
  if [ -n "$file" ] && [ -n "$line" ]; then
    nvim -c $line $file
  else
    echo "...Canceled"
  fi
}

function texit(){
  if [[ -n "$TMUX" ]] ; then
    tmux run "mkdir -p ~/.tmux/logs/\$(date +%Y%m%d);tmux capture-pane -S -10000000; tmux show-buffer > \${HOME}/.tmux/logs/\$(date +%Y%m%d)/\$(date +%Y%m%d-%H%M%S)-#S-#I.#P.log" \; display-message "Logging ..."
    builtin exit
  else
    builtin exit
  fi
}

function td() {
  date +%Y%m%d%S
}

in_container() {
  container="$1"
  shift # command: the rest
  if [ -z "$*" ] ; then
    podman exec -it "$container" env PS1="$container $PS1" env TERM="$TERM" /bin/bash
  else
    podman exec "$container" env TERM="$TERM" "$@"
  fi
}

function tmux-remake-socket() {
    if [ ! $TMUX ]; then
        return
    fi
    tmux_socket_file=`echo $TMUX|awk -F, '{print $1}'`
    if [ ! -S $tmux_socket_file ]; then
        mkdir -m700 `dirname $tmux_socket_file` 2> /dev/null
        killall -SIGUSR1 tmux
    else
        echo tmux unix domain socket exists! nothing to do.
    fi
    unset tmux_socket_file
}
function split_k8s_yaml() {
    local parent_dir="."
    local OPTIND opt

    # オプション解析
    while getopts "d:h" opt; do
        case $opt in
            d) parent_dir="$OPTARG" ;;
            h) 
                cat << 'EOF'
split_k8s_yaml - Kubernetesからエクスポートしたリソース定義を分割

使い方:
    split_k8s_yaml [-d PARENT_DIR]

オプション:
    -d PARENT_DIR   リソースディレクトリを含む親ディレクトリ（デフォルト: カレントディレクトリ）
    -h              このヘルプを表示

各リソースディレクトリ内の *.yml および *.yaml ファイルを読み込み、
個別オブジェクトに分割します。

ファイル名は以下のように生成されます:
  - namespace がある場合: {namespace}_{name}.yaml
  - namespace がない場合: {name}.yaml

必要なツール: yq (https://github.com/mikefarah/yq)
EOF
                return 0
                ;;
            \?) 
                echo "無効なオプション: -$OPTARG" >&2
                return 1
                ;;
        esac
    done
    
    # yqの存在確認
    if ! command -v yq >/dev/null 2>&1; then
        echo "エラー: yq コマンドが見つかりません。" >&2
        echo "インストール方法:" >&2
        echo "  brew install yq" >&2
        echo "  または https://github.com/mikefarah/yq#install を参照" >&2
        return 1
    fi
    
    parent_dir=$(realpath "$parent_dir")
    
    if [[ ! -d "$parent_dir" ]]; then
        echo "エラー: ディレクトリが存在しません: $parent_dir" >&2
        return 1
    fi
    
    # 各サブディレクトリを処理
    for dir in "$parent_dir"/*(/); do
        if [[ -d "$dir" ]]; then
            # YAMLファイルを検索
            for yaml_file in "$dir"/*.{yml,yaml}(N); do
                [[ -f "$yaml_file" ]] || continue
                
                echo "Processing: $yaml_file"
                _split_yaml_docs "$yaml_file" "$dir"
            done
        fi
    done
}

# YAMLファイルを分割する内部関数
_split_yaml_docs() {
    local input_file="$1"
    local output_dir="$2"
    local temp_file
    
    # 一時ファイル作成
    temp_file=$(mktemp)
    trap "rm -f '$temp_file'" EXIT
    
    # まずitemsフィールドがあるかチェック
    if yq eval '.items' "$input_file" >/dev/null 2>&1 && [[ "$(yq eval '.items | type' "$input_file")" == "!!seq" ]]; then
        # itemsフィールドがある場合（kubectl get -o yaml の出力形式）
        local items_count
        items_count=$(yq eval '.items | length' "$input_file")
        
        for ((i=0; i<items_count; i++)); do
            # 各アイテムを抽出
            yq eval ".items[$i]" "$input_file" > "$temp_file"
            _write_individual_yaml "$temp_file" "$output_dir"
        done
    else
        # ドキュメント区切り(---)で分割されている場合
        # 一時的に各ドキュメントを分離
        local doc_count=0
        
        # yqを使って各ドキュメントを処理
        yq eval-all '. as $item ireduce (0; . + 1)' "$input_file" | while read -r count; do
            doc_count=$count
        done
        
        # 各ドキュメントを個別に処理
        local doc_index=0
        yq eval-all --no-doc '. as $item | $item' "$input_file" | while IFS= read -r -d '' doc || [[ -n "$doc" ]]; do
            if [[ -n "$doc" && "$doc" != "null" ]]; then
                echo "$doc" > "$temp_file"
                _write_individual_yaml "$temp_file" "$output_dir"
            fi
        done
        
        # より確実な方法：split-exp を使用
        yq eval-all --no-doc 'select(. != null)' "$input_file" \
        | yq eval-all --no-doc '. as $item | $item' - \
        | while IFS= read -r line; do
            if [[ "$line" == "---" ]] || [[ -z "$line" ]]; then
                if [[ -s "$temp_file" ]]; then
                    _write_individual_yaml "$temp_file" "$output_dir"
                    > "$temp_file"  # ファイルをクリア
                fi
            else
                echo "$line" >> "$temp_file"
            fi
        done
        
        # 最後のドキュメントを処理
        if [[ -s "$temp_file" ]]; then
            _write_individual_yaml "$temp_file" "$output_dir"
        fi
    fi
}

# 個別のYAMLファイルを書き出す内部関数
_write_individual_yaml() {
    local temp_file="$1"
    local output_dir="$2"
    local name namespace filename output_path
    
    # メタデータから名前と名前空間を取得
    name=$(yq eval '.metadata.name // ""' "$temp_file" 2>/dev/null)
    namespace=$(yq eval '.metadata.namespace // ""' "$temp_file" 2>/dev/null)
    
    if [[ -z "$name" ]]; then
        echo "警告: メタデータに名前がありません。スキップします。" >&2
        return 1
    fi
    
    # ファイル名を生成
    if [[ -n "$namespace" ]]; then
        filename="${namespace}_${name}.yaml"
    else
        filename="${name}.yaml"
    fi
    
    output_path="$output_dir/$filename"
    
    # ファイルを書き出し
    cp "$temp_file" "$output_path"
    echo "Written: $output_path"
}

# 関数をエクスポート（他のスクリプトからも使用可能にする）
# .zshrc に追加する場合は以下の行をコメントアウト
# split_k8s_yaml "$@"
oc-all () {
    local verbose_mode=false
    local all_namespaces=false
    local is_save=false
    local namespace_arg=""
    local -a exclude_list=("packagemanifests.packages.operators.coreos.com" "clusterserviceversions.operators.coreos.com" "events" "events.events.k8s.io" "pods.metrics.k8s.io")

    local help_message=$'
Usage: oc-all [options]
Options:
  -v, --verbose        Show all resources including excluded ones
  -A, --all            Query across all namespaces
  -n, --namespace NS   Specify a namespace (default is current context)
  --help               Show this help message
  save                 Save output YAMLs to ./save directory
'

    # 最後の引数が "save" の場合
    if [[ "${@[-1]}" == "save" ]]; then
        is_save=true
        set -- "${(@)@[1,-2]}"
    fi

    # パース
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                verbose_mode=true
                shift ;;
            -A|--all)
                all_namespaces=true
                shift ;;
            -n|--namespace)
                if [[ -z "$2" ]]; then
                    echo "Error: --namespace requires a value"
                    echo "$help_message"
                    return 1
                fi
                namespace_arg="$2"
                shift 2 ;;
            --help)
                echo "$help_message"
                return 0 ;;
            save)
                # 既に処理済みなので無視
                shift ;;
            -*)
                echo "Error: Unknown option: $1"
                echo "$help_message"
                return 1 ;;
            *)
                echo "Error: Unexpected argument: $1"
                echo "$help_message"
                return 1 ;;
        esac
    done

    # namespace の自動補完
    if [[ -z "$namespace_arg" && "$all_namespaces" != true ]]; then
        namespace_arg=$(kubectl config view --minify -o 'jsonpath={..namespace}')
        [[ -z "$namespace_arg" ]] && namespace_arg="default"
    fi

    local ns_flag
    local ns_file_label
    if [[ "$all_namespaces" == true ]]; then
        ns_flag="--all-namespaces"
        ns_file_label="all"
    else
        ns_flag="--namespace ${namespace_arg}"
        ns_file_label="$namespace_arg"
    fi

    local GREEN="$(tput bold; tput setaf 2)"
    local RESET="$(tput sgr0)"
    local exclude_str="${exclude_list[*]}"

    kubectl api-resources --namespaced=true --verbs=list -o name | xargs -n1 -P4 -I{} bash -c '
        resource="$1"; ns_flag="$2"; verbose="$3"; excludes="$4"; green="$5"; reset="$6"; is_save="$7"; ns_file_label="$8"

        for excl in $excludes; do
            if [[ "$verbose" != "true" && "$resource" == "$excl" ]]; then
                exit 0
            fi
        done

        output=$(kubectl get "$resource" $ns_flag --show-kind --ignore-not-found 2>/dev/null)

        if [[ -n "$output" && "$output" != "No resources found"* ]]; then
            echo -e "\n${green}### $resource ###${reset}"
            echo "$output"

            if [[ "$is_save" == "true" ]]; then
                echo "saving..."
                mkdir -p ./save_manifests/"$resource"
                kubectl get "$resource" $ns_flag --ignore-not-found -o yaml > "./save_manifests/$resource/${ns_file_label}.yaml"
            fi
        fi
    ' _ {} "$ns_flag" "$verbose_mode" "$exclude_str" "$GREEN" "$RESET" "$is_save" "$ns_file_label"

    echo -e "$RESET"

    if [[ "$is_save" == "true" ]]; then
        split_k8s_yaml ./save_manifests/
    fi
}
function oc-ns() {
  # 1. oc から Namespace の一覧を取得し、peco で選択
  #    --no-headers: ヘッダー行を省略
  #    -o custom-columns=:metadata.name: Namespace 名だけを出力
  local ns
  ns=$(oc get namespace --no-headers -o custom-columns=:metadata.name | peco)

  # 2. 選択結果が空でなければ、現在のコンテキストの Namespace を切り替え
  if [[ -n "$ns" ]]; then
    oc config set-context --current --namespace="$ns" >/dev/null
    echo "🔄 Namespace を '$ns' に切り替えました"
  else
    # peco で何も選択せずに Ctrl-C や Esc した場合など
    echo "⚠️ Namespace が選択されませんでした"
    return 1
  fi
}

# function fzf-history-widget() {
#     local tac=${commands[tac]:-"tail -r"}
#     BUFFER=$( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | sed 's/ *[0-9]* *//' | eval $tac | awk '!a[$0]++'|sed 's/^\* //g' | fzf --exact +s)
#     CURSOR=$#BUFFER
#     zle clear-screen
# }
# zle     -N   fzf-history-widget
# bindkey '^R' fzf-history-widget
kubectl() {
  if [ "$1" = "get" ]; then
    shift
    command kubectl get --show-kind "$@"
  else
    command kubectl "$@"
  fi
}

oc() {
  if [ "$1" = "get" ]; then
    shift
    command oc get --show-kind "$@"
  else
    command oc "$@"
  fi
}


tar() {
  COPYFILE_DISABLE=1 command tar "$@"
}

zsh-clear-cache() {
  rm -f "$HOME/.zsh/cache/"*.zsh "$HOME/.zsh/cache/"*.zsh.zwc
  echo "ZSH caches cleared. Restart shell to regenerate."
}
