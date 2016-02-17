##TODO##
- Currently some parts of order state transition happen outside db transaction. Find out a way to ensure they are always successful.
- Use metaprogramming to auto generate state change methods.
- Currently uses a dummy product table called ```not_product```
- Order confirmation does not change the available quantity.
- Make state forms more explicit in terms of what state they belong to. Currently very counter-intuitive in their behaviour.
