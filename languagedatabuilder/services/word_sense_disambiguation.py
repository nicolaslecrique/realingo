

# 1) we load all sentences
# 2) we pass every sentences in the model
# 3) we get embedded vector for each word
# 4)


# IDEE: utiliser les embedding qui viennent des trucs fine tuned pour la similarity plutot que les embedding de masked model ???
# ca peut mieux marcher pour évaluer les clusters de embeddings
# https://www.sbert.net/docs/pretrained_models.html

# https://huggingface.co/pvl/labse_bert

# LABSE is the best
# https://huggingface.co/pvl/labse_bert

# Idee to check si un mot est bien utilisé dans le contexte e la phrase: embedding dans la phrase vS embedding seul



# Idée: on fait une grande matrice language source -> language target
# on traduit toutes les phrases, pour chaque pair, on fait +1 sur la matrice de coocurrence
# à la fin on regarde la fréquence de cooccurence par rapport à la fréquence générale
# si elle est très elevée c'est probablement une traduction possibe
# si en plus ils apparaissent ensembles et à la suite c'est probablement un mot qui se traduit en plusieurs tokens
