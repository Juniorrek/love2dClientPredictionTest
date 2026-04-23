local inputBuffer = {
    nextSeq = 0,
    pending = {}
}

function inputBuffer.push(input)
    inputBuffer.pending[#inputBuffer.pending + 1] = input
end

function inputBuffer.removeAcknowledged(lastSeq)
    local new = {}
    for i = 1, #inputBuffer.pending do
        if inputBuffer.pending[i].seq > lastSeq then
            new[#new+1] = inputBuffer.pending[i]
        end
    end

    inputBuffer.pending = new
end

return inputBuffer