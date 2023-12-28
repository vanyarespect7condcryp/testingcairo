# cairo-compile linear_function.cairo --output linear_function_compiled.json
# cairo-run --program=linear_function_compiled.json --print_output --layout=small --program_input=linear_function_input.json 

%builtins output

from starkware.cairo.common.serialize import serialize_word, serialize_array
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc,get_label_location


func linear_function{output_ptr: felt*}(inputs: felt*, weights: felt*, intercept:felt, size) -> (sum):
	if size == 0:
        serialize_word(intercept)
		return (sum=intercept)
	end
	
	let (sum_of_rest) = linear_function(inputs=inputs+1, weights=weights+1, intercept=intercept, size=size-1)
    serialize_word([inputs])
    serialize_word([weights])
    let sum = sum_of_rest + [inputs]*[weights] 
	return (sum=sum)
end

func main{output_ptr: felt*}():
	alloc_locals

    local intercept: felt
	local weights : felt* 
	local inputs : felt* 	
	local size
	
	%{
intercept = int(program_input['intercept'])
ids.intercept = intercept 

weight_list = program_input['weights']
ids.weights = weights = segments.add()
for i, val in enumerate(weight_list):
	memory[weights + i] = val
input_list = program_input['X'][0]

ids.inputs = inputs = segments.add()
for i, val in enumerate(input_list):
	memory[inputs + i] = val	
ids.size = len(input_list)	
	%}
	#serialize_array(inputs,size,1,get_label_location('serialize_word'))
	#serialize_array(weights,size,1,get_label_location('serialize_word'))	
    serialize_word(size)
	let (sum) = linear_function(inputs=inputs, weights=weights, intercept=intercept, size=size)
	
	serialize_word(sum)
	return()
end
