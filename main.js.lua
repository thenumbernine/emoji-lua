import { EmbeddedLuaInterpreter } from '/js/lua.vm-util.js.lua';
import { DOM } from '/js/util.js';
<?
xpcall(function()

math.randomseed(os.time())

local path = require 'ext.path'
local string = require 'ext.string'

local s = assert(path'emojis.txt':read())
local d = string.split(s, '\n')
if d[#d] == '' then d[#d] = nil end

local json = require 'dkjson'
?>
const d = <?=json.encode(d)?>;

const legend = [
	{name:'keyword', symbols:`
and       break     do        else      elseif    end
false     for       function  goto      if        in
local     nil       not       or        repeat    return
then      true      until     while
`},
	{name:'symbol', symbols:`
+     -     *     /     %     ^     #
==    ~=    <=    >=    <     >     =
(     )     {     }     [     ]     ::
;     :     ,     .     ..    ...

' " \\
`},
	{name:'global', symbols:`
_G _VERSION assert bit32 collectgarbage coroutine debug dofile error getmetatable io ipairs js load loadfile loadstring math module next os package pairs pcall print rawequal rawget rawlen rawset require select setmetatable string t table tonumber tostring type unpack xpcall
`},
	{name:'string', symbols:`
string.byte string.char string.dump string.find string.format string.gmatch string.gsub string.len string.lower string.match string.rep string.reverse string.sub string.upper 
`},
	{name:'table', symbols:`
table.concat table.insert table.maxn table.pack table.remove table.sort table.unpack
`},
	{name:'math', symbols:`
math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.cosh math.deg math.exp math.floor math.fmod math.frexp math.huge math.ldexp math.log math.log10 math.max math.min math.modf math.pi math.pow math.rad math.random math.randomseed math.sin math.sinh math.sqrt math.tan math.tanh 
`},
	{name:'bit32', symbols:`
bit32.arshift bit32.band bit32.bnot bit32.bor bit32.btest bit32.bxor bit32.extract bit32.lrotate bit32.lshift bit32.replace bit32.rrotate bit32.rshift 
`},
	{name:'io', symbols:`
io.close io.flush io.input io.lines io.open io.output io.popen io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write 
seek setvbuf 
`},
	{name:'os', symbols:`
os.clock os.date os.difftime os.execute os.exit os.getenv os.remove os.rename os.setlocale os.time os.tmpname 
`},
	{name:'coroutine', symbols:`
coroutine.create coroutine.resume coroutine.running coroutine.status coroutine.wrap coroutine.yield 
`},
	{name:'package', symbols:`
package.config package.cpath package.loaded package.loaders package.loadlib package.path package.preload package.searchers package.searchpath package.seeall 
`},
	{name:'debug', symbols:`
debug.debug debug.gethook debug.getinfo debug.getlocal debug.getmetatable debug.getregistry debug.getupvalue debug.getuservalue debug.sethook debug.setlocal debug.setmetatable debug.setupvalue debug.setuservalue debug.traceback debug.upvalueid debug.upvaluejoin 
`},
	{name:'meta', symbols:`
__add __sub __mul __div __mod __pow __unm __concat __len __eq __lt __le __index __newindex __call __tostring __metatable __gc 
`},
];

legend.forEach((l,i) => {
	l.symbols = l.symbols.trim().split(/\s+/);
});

const allpairs = [];
legend.forEach((l,i) => {
	l.emojis = [];
	l.symbols.forEach((sym,j) => {
		const k = parseInt(Math.random() * d.length);
		const emoji = d.splice(k, i)[0];
		l.emojis.push(emoji)
		allpairs.push([sym, emoji])
	});
});
allpairs.sort((a,b) => {
	return (a[1] || []).length - (b[1] || []).length;
});

let addChar;
const emojiLua = document.getElementById('emojiLua');
DOM('a', {
	href : 'https://www.lua.org/manual/5.2/manual.html',
	text : 'Lua 5.2 Manual',
	appendTo : emojiLua,
});
const table = DOM('table', {appendTo : emojiLua});
{
	const tr1 = DOM('tr', {appendTo : table});
	legend.forEach((l,i) => {
		DOM('td', {text:l.name, appendTo : tr1});
	});
	const tr = DOM('tr', {appendTo : table});
	legend.forEach((l,i) => {
		const td = DOM('td', {appendTo : tr});
		l.emojis.forEach((emoji,j) => {
			let span = DOM('span', {class:'tooltip', appendTo : td});
			let a = DOM('a', {
				appendTo : span,
				click : e => {
					addChar(emoji);
				},
				text : emoji,
			});
			DOM('span', {class:'tooltiptext', text:l.symbols[j], appendTo : span});
		});
	});
}

class ThisEmbeddedLuaInterpreter extends EmbeddedLuaInterpreter {
	executeAndPrint(s) {
		Module.print('> '+s);
		allpairs.forEach(p => {
			let [k,e] = p;
			if (k == "'") {
				k = "\\'";
			} else if (k == '"') {
			} else {
				k = ' '+k+' ';
			}
			s = s.replaceAll(e, k);
		});
		//Module.print('> '+s);
		this.execute(s);
	}
}
const interpretter = new ThisEmbeddedLuaInterpreter({
	id : 'lua-vm-container',
	packages : ['ext'],
	autoLaunch : true,
	done : function() {
		//output.empty();
		this.execute("package.path = package.path .. ';./?/init.lua'");
	}
});
addChar = (c) => {
	interpretter.input.value += c;
};

<?
end, function(err)
	?><?=err..'\n'..debug.traceback()?><?
end)
?>
