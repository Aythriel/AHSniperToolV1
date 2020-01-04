if opRez.getvalue() == 0:
                return "Ok. Password changed."
            else:
                return "Failed to update password."

create or replace TRIGGER CALCULATE_DISCOUNT
		BEFORE INSERT ON AUCTIONS
		FOR EACH ROW
		DECLARE
			v_discount auctions.discount%TYPE;
			v_avg items.average_price%TYPE;
		BEGIN
                v_discount := 0.0;
				SELECT items.average_price INTO v_avg FROM ITEMS WHERE items.id = :NEW.ID_ITEM;
                IF v_avg IS NULL THEN
                    v_avg :=1.0;
                END IF;
				v_discount :=  (1.0 - (:NEW.BUYOUT_VALUE / v_avg )) * 100; 
				:NEW.DISCOUNT := v_discount;
END CALCULATE_DISCOUNT;