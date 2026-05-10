module.exports = async function router(req, config) {
  const requestedModel = req.body?.model || "";
  
  if (requestedModel.includes("opus")) {
    return "ollama-local,llama3:70b";
  }
  
  if (requestedModel.includes("sonnet") || requestedModel.includes("haiku")) {
    return "ollama-local,gemma4:34b";
  }
  
  return null;
};
